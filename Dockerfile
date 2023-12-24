FROM golang:1.21 AS deps

ARG LINKER_FLAGS=$LINKER_FLAGS

ARG DB_DSN
ENV DB_DSN $DB_DSN

WORKDIR /talkliketv
ADD *.mod *.sum ./
RUN go mod download

FROM deps as dev
ADD . .
EXPOSE 4000
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="$LINKER_FLAGS" -o=./web ./cmd/web
CMD /talkliketv/web -db-dsn=$DB_DSN

FROM scratch as prod

WORKDIR /
EXPOSE 4000
COPY --from=dev /talkliketv/web /
CMD ["/web"]