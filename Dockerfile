# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


# auto-fix: pinned digest for golang:1.25-bookworm to ensure reproducible builds
FROM golang:1.25-bookworm@sha256:154bd7001b6eb339e88c964442c0ad6ed5e53f09844cc818a41ce4ecb3ce3b43 AS builder

WORKDIR /usr/src/app/

COPY ./go.mod go.mod
COPY ./go.sum go.sum

RUN go mod download

COPY ./genproto/oteldemo/ genproto/oteldemo/
COPY ./kafka/ kafka/
COPY ./money/ money/
COPY ./main.go main.go

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o checkout main.go

# auto-fix: pinned digest for gcr.io/distroless/static-debian12:nonroot to ensure reproducible builds
FROM gcr.io/distroless/static-debian12:nonroot@sha256:d093aa3e30dbadd3efe1310db061a14da60299baff8450a17fe0ccc514a16639

WORKDIR /usr/src/app/

COPY --from=builder /usr/src/app/checkout ./

EXPOSE ${CHECKOUT_PORT}
ENTRYPOINT [ "./checkout" ]
