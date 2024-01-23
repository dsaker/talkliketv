package main

import (
	"flag"
	"fmt"
	pg "github.com/habx/pg-commands"
	"os"
)

func main() {

	dumpCommand := flag.NewFlagSet("dump", flag.ExitOnError)
	restoreCommand := flag.NewFlagSet("restore", flag.ExitOnError)

	dumpDb := dumpCommand.String("db-name", "", "postgres database (Required)")
	dumpHost := dumpCommand.String("host", "localhost", "postgres database host")
	dumpPort := dumpCommand.Int("port", 5432, "postgres database port")
	dumpUsername := dumpCommand.String("username", "", "postgres database username (Required)")
	dumpPassword := dumpCommand.String("password", "", "postgres database password (Required)")

	restoreDb := restoreCommand.String("db-name", "", "postgres database (Required)")
	restoreHost := restoreCommand.String("host", "localhost", "postgres database host (Required)")
	restorePort := restoreCommand.Int("port", 5432, "postgres database port")
	restoreUsername := restoreCommand.String("username", "", "postgres database username (Required)")
	restorePassword := restoreCommand.String("password", "", "postgres database password (Required)")
	restoreFilePath := restoreCommand.String("filepath", "", "filepath to restore (Required)")

	if len(os.Args) < 2 {
		fmt.Println("dump or restore subcommand is required")
		os.Exit(1)
	}

	switch os.Args[1] {
	case "dump":
		err := dumpCommand.Parse(os.Args[2:])
		if err != nil {
			panic(err)
		}
	case "restore":
		err := restoreCommand.Parse(os.Args[2:])
		if err != nil {
			panic(err)
		}
	default:
		flag.PrintDefaults()
		os.Exit(1)
	}

	// Check which subcommand was Parsed using the FlagSet.Parsed() function. Handle each case accordingly.
	// FlagSet.Parse() will evaluate to false if no flags were parsed (i.e. the user did not provide any flags)
	if dumpCommand.Parsed() {
		// Required Flags
		if *dumpPassword == "" || *dumpDb == "" || *dumpUsername == "" {
			dumpCommand.PrintDefaults()
			os.Exit(1)
		}

		dbDump(dumpPort, dumpHost, dumpDb, dumpUsername, dumpPassword)
	}

	if restoreCommand.Parsed() {
		// Required Flags
		if *restoreFilePath == "" || *restorePassword == "" || *restoreDb == "" || *restoreUsername == "" {
			restoreCommand.PrintDefaults()
			os.Exit(1)
		}

		dbRestore(restorePort, restoreHost, restoreDb, restoreUsername, restorePassword, restoreFilePath)
	}
}

func dbDump(port *int, host, db, username, password *string) {

	dump, err := pg.NewDump(&pg.Postgres{
		Host:     *host,
		Port:     *port,
		DB:       *db,
		Username: *username,
		Password: *password,
	})
	if err != nil {
		panic(err)
	}

	dumpExec := dump.Exec(pg.ExecOptions{StreamPrint: false})
	if dumpExec.Error != nil {
		fmt.Println(dumpExec.Error.Err)
		fmt.Println(dumpExec.Output)
	} else {
		fmt.Println("Dump success")
		fmt.Println(dumpExec.Output)
	}
}

func dbRestore(port *int, host, db, username, password, filepath *string) {

	restore, _ := pg.NewRestore(&pg.Postgres{
		Host:     *host,
		Port:     *port,
		DB:       *db,
		Username: *username,
		Password: *password,
	})

	restoreExec := restore.Exec(*filepath, pg.ExecOptions{StreamPrint: false})
	if restoreExec.Error != nil {
		fmt.Println(restoreExec.Error.Err)
		fmt.Println(restoreExec.Output)

	} else {
		fmt.Println("Restore success")
		fmt.Println(restoreExec.Output)

	}
}
