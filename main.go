package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

var (
	pin1File string
	pin2File string
	musicDir string
)

func init() {
	flag.StringVar(&pin1File, "pin1", "/sys/class/gpio/gpio11/value", "Filename of pin 1 'value'")
	flag.StringVar(&pin2File, "pin2", "/sys/class/gpio/gpio12/value", "Filename of pin 2 'value'")
	flag.StringVar(&musicDir, "music", ".", "Directory containing music")
	flag.Parse()
}

func main() {
	if _, err := os.Stat(pin1File); err != nil {
		log.Fatalf("Pin 1 failed: %#v\n", err)
	}
	if _, err := os.Stat(pin2File); err != nil {
		log.Fatalf("Pin 2 failed: %#v\n", err)
	}
	if _, err := os.Stat(musicDir); err != nil {
		log.Fatalf("Music directory failed: %#v\n", err)
	}

	var cmd *exec.Cmd
	for {
		pin1 := readPin(pin1File)
		//pin2 := readPin(pin2File)

		if pin1 {
			if cmd == nil {
				fmt.Println("starting playing music")
				files := getMusicFiles(musicDir)
				args := append([]string{"-Z"}, files...)
				cmd = exec.Command("/usr/bin/mpg123", args...)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				if err := cmd.Start(); err != nil {
					fmt.Printf("Playing music failed: %#v\n", err)
				} else {
					fmt.Println("started playing music")
				}
			}
		} else {
			if cmd != nil {
				fmt.Println("stopping playing music")
				if p := cmd.Process; p != nil {
					p.Signal(syscall.SIGKILL)
					cmd.Wait()
				}
				cmd = nil
				fmt.Println("stopped playing music")
			}
		}
		time.Sleep(time.Second)
	}
}

func readPin(pinFile string) bool {
	content, err := ioutil.ReadFile(pinFile)
	if err != nil {
		log.Fatalf("Failed to read pin %s: %#v\n", pinFile, err)
	}
	return strings.TrimSpace(string(content)) == "1"
}

func getMusicFiles(dir string) []string {
	entries, err := ioutil.ReadDir(dir)
	if err != nil {
		return nil
	}
	result := make([]string, 0, len(entries))
	for _, e := range entries {
		if strings.HasSuffix(e.Name(), ".mp3") {
			result = append(result, filepath.Join(dir, e.Name()))
		}
	}
	return result
}
