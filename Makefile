BIN:=alpmusic

all: $(BIN)

clean:
	rm -f $(BIN)

$(BIN): main.go
	GOOS=linux GOARCH=arm go build -o $(BIN) .