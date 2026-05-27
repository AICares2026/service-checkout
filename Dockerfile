# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


FROM golang:1.25-bookworm AS builder

WORKDIR /usr/src/app/

COPY ./go.mod go.mod
COPY ./go.sum go.sum

RUN go mod download

COPY ./genproto/oteldemo/ genproto/oteldemo/
COPY ./kafka/ kafka/
COPY ./money/ money/
COPY ./main.go main.go

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o checkout main.go

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /usr/src/app/

COPY --from=builder /usr/src/app/checkout ./

EXPOSE ${CHECKOUT_PORT}
ENTRYPOINT [ "./checkout" ]
