package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

type cue struct {
	Start time.Duration
	End   time.Duration
	Text  string
}

func (c *cue) String() string {
	return fmt.Sprintf(
		"%s --> %s\n%s\n",
		formatCueTime(c.Start),
		formatCueTime(c.End),
		c.Text,
	)
}

func (c *cue) Duration() time.Duration {
	return c.End - c.Start
}

func parseCueSeconds(str string) (time.Duration, error) {
	slices := strings.SplitN(str, ".", 2)
	if len(slices) == 0 {
		return 0, nil
	} else if len(slices) == 1 {
		sec, err := strconv.Atoi(slices[0])
		if err != nil {
			return 0, err
		}
		return time.Duration(sec) * time.Second, nil
	} else {
		rationalPart := slices[1]

		if len(rationalPart) > 3 {
			rationalPart = rationalPart[:3]
		} else if len(rationalPart) < 3 {
			rationalPart = fmt.Sprintf("%03s", rationalPart)
		}

		sec, err := strconv.Atoi(slices[0])

		if err != nil {
			return 0, err
		}

		milli, err := strconv.Atoi(rationalPart)

		if err != nil {
			return 0, err
		}

		return time.Duration(sec)*time.Second +
			time.Duration(milli)*time.Millisecond, nil
	}
}

func formatCueTime(d time.Duration) string {
	fullMS := d.Milliseconds()
	hours := fullMS / time.Hour.Milliseconds()
	minutes := fullMS / time.Minute.Milliseconds() % 60
	seconds := fullMS / time.Second.Milliseconds() % 3600
	ms := fullMS % 1000

	return fmt.Sprintf(
		"%02d:%02d:%02d.%03d",
		hours, minutes, seconds, ms,
	)
}

func readTimeline(path string) ([]cue, error) {
	r, err := os.Open(path)

	if err != nil {
		return nil, err
	}

	defer r.Close()

	ret := make([]cue, 0)
	scanner := bufio.NewScanner(r)

	i := 1
	for scanner.Scan() {
		// FIXME: don't assume text is always single char Chinese. Allow phrases.
		// for example: 1.20 2.30 we chose to go to the moon
		slices := strings.Fields(scanner.Text())

		if len(slices) != 2 && len(slices) != 3 {
			return nil, fmt.Errorf("%s:%d: Read %d fields, expecting 2 or 3 fields", path, i, len(slices))
		}

		startTS, err := parseCueSeconds(slices[0])
		if err != nil {
			return nil, err
		}

		endTS, err := parseCueSeconds(slices[1])
		if err != nil {
			return nil, err
		}

		if endTS < startTS {
			return nil, fmt.Errorf("%s:%d: End time must be equal or after start time", path, i)
		}

		var text string
		if len(slices) == 3 {
			text = slices[2]
		}

		ret = append(ret, cue{
			Start: startTS,
			End:   endTS,
			Text:  text,
		})

		i++
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "reading file:", err)
	}

	return ret, nil
}

func breakCues(cues []cue, stretch time.Duration) []cue {
	ret := []cue{}

	for _, c := range cues {
		// break cue if longer than stretch duration
		for c.Duration() > stretch {
			newCue := cue{Start: c.Start, End: c.Start + stretch}
			ret = append(ret, newCue)
			c.Start = newCue.End
		}
		ret = append(ret, c)
	}

	return ret
}

func main() {
	stretchVar := flag.Int("stretch", 3, "max cue duration in seconds")
	sepVar := flag.String("sep", "", "word separator. Used for Latin scripts")

	flag.Parse()
	vadFilename := flag.Arg(0)
	sttFilename := flag.Arg(1)
	stretch := time.Duration(*stretchVar) * time.Second
	sep := *sepVar

	vttCue, err := readTimeline(vadFilename)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	newVTTCues := breakCues(vttCue, stretch)

	words, err := readTimeline(sttFilename)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("WEBVTT")
	fmt.Println("")

	j := 0

	for _, sentence := range newVTTCues {
		var sb strings.Builder

		for j < len(words) {
			word := words[j]

			if word.End < sentence.End {
				sb.WriteString(word.Text)
				sb.WriteString(sep)
			} else {
				break
			}

			j++
		}

		if sb.Len() == 0 {
			continue
		}

		sentence.Text = sb.String()
		fmt.Println(sentence.String())
	}
}
