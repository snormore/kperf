package iperf

import "log"

// TestSuite ...
type TestSuite struct{}

// Test ...
type Test struct{}

// Run ...
func (s *TestSuite) Run() {
	log.Println("Running the tests!")
}
