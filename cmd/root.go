package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	// PackageName is the package name added during build.
	PackageName string

	// GitCommit is the git SHA of the current commit added during build.
	GitCommit string

	// Version is the user-defined version identifier during build.
	Version string

	// BuildTimestamp is the seconds-since-epoch timestamp added during build.
	BuildTimestamp string
)

var rootCmd = &cobra.Command{
	Use: PackageName,
	Run: func(cmd *cobra.Command, args []string) {},
}

// Execute is the CLI entrypoint.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
