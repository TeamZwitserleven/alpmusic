BIN:=alpmusic

all: $(BIN)

clean:
	rm -f $(BIN)

$(BIN):
	GOOS=linux GOARCH=arm go build -o $(BIN) .