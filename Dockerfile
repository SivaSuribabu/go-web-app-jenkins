# i want to creat a multi stage  docker file for my go lang application

# Step 1: Build the go application

FROM golang:1.22.5 as builder

WORKDIR /app

COPY go.mod ./


RUN go mod download

COPY . .

RUN go build -o main .

# Step 2: Run the go application

FROM gcr.io/distroless/base

COPY --from=builder /app/main .

COPY --from=builder /app/static  ./static

EXPOSE 8080

CMD ["./main"]