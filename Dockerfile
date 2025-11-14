# Dockerfile
ARG GO_IMAGE=golang:1.25-alpine
ARG GO_DELVE_VERSION=v1.25.1
ARG PROJECT_ROOT=/app

# ----------------------------------------------------------------
## Stage: base
# Prepares the common environment for all Go-related tasks.
# ----------------------------------------------------------------
FROM ${GO_IMAGE} AS base

ARG PROJECT_ROOT

WORKDIR ${PROJECT_ROOT}
ENV PROJECT_ROOT=${PROJECT_ROOT}

# Expose the port
EXPOSE 8080

# Install common OS packages
RUN apk add --no-cache \
        # Essential shell and networking
        bash \
        ca-certificates \
        # init process for proper signal handling and zombie reaping for development
        tini \
        # Version control (needed for go mod)
        git; \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# ----------------------------------------------------------------
## Stage: builder
# Builds the final, static application binary for production.
# ----------------------------------------------------------------
FROM base AS builder

# First, copy only module files and download dependencies.
# This creates a cacheable layer for the build.
COPY go.mod go.sum .
RUN go mod tidy

# Copy the rest of the source code
COPY . .

# Build the Go application, creating a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -o /go-hello-app .

# ----------------------------------------------------------------
## Stage: local
# For local development using `go run`.
# ----------------------------------------------------------------
FROM base AS local

ARG GO_DELVE_VERSION

# Install development tools like the debugger.
RUN CGO_ENABLED=0 go install -ldflags "-s -w -extldflags '-static'" github.com/go-delve/delve/cmd/dlv@${GO_DELVE_VERSION}

# ----------------------------------------------------------------
## Stage: production
# The final, lean production image containing only the compiled binary.
# ----------------------------------------------------------------
FROM alpine:latest AS production

ARG PROJECT_ROOT

WORKDIR ${PROJECT_ROOT}
ENV PROJECT_ROOT=${PROJECT_ROOT}

# Expose the port
EXPOSE 8080

# Copy only the compiled binary from the builder stage
COPY --from=builder /go-hello-app /go-hello-app

# Command to run the application when the container starts
ENTRYPOINT ["/go-hello-app"]