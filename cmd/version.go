package cmd

import (
	"fmt"
	"strconv"
	"time"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(versionCmd)
}

var versionCmd = &cobra.Command{
	Use: "version",
	Run: func(cmd *cobra.Command, args []string) {
		seconds, err := strconv.ParseInt(BuildTimestamp, 10, 64)
		if err != nil {
			fmt.Println(err)
		}
		buildTime := time.Unix(0, seconds*int64(time.Second))
		fmt.Println(PackageName, Version, GitCommit, buildTime)
	},
}
