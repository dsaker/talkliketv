package assert

import (
	"cmp"
	"strings"
	"testing"
)

func Equal[E comparable](t *testing.T, actual, expected E) {
	t.Helper()

	if actual != expected {
		t.Errorf("got: %v; want: %v", actual, expected)
	}
}

func GreaterThan[E cmp.Ordered](t *testing.T, actual, expected E) {
	t.Helper()

	if actual <= expected {
		t.Errorf("got: %v; want: %v", actual, expected)
	}
}

func NotEqual[T comparable](t *testing.T, actual, expected T) {
	t.Helper()

	if actual == expected {
		t.Errorf("got: %v; want: %v", actual, expected)
	}
}

func StringContains(t *testing.T, actual, expectedSubstring string) {
	t.Helper()

	if !strings.Contains(actual, expectedSubstring) {
		t.Errorf("got: %q; expected to contain: %q", actual, expectedSubstring)
	}
}

func NilError(t *testing.T, actual error) {
	t.Helper()

	if actual != nil {
		t.Errorf("got: %v; expected: nil", actual)
	}
}
