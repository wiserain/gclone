package main

import (
	_ "github.com/wiserain/gclone/backend/all" // import all backends
	"github.com/rclone/rclone/cmd"
	_ "github.com/wiserain/gclone/cmd/copy"
	_ "github.com/rclone/rclone/cmd/all"    // import all commands
	"github.com/rclone/rclone/fs"
	_ "github.com/rclone/rclone/lib/plugin" // import plugins
)

func main() {
	fs.Version = "v1.53.1-mod1.4.0"
	cmd.Main()
}
