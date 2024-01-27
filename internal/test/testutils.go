package test

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	pg "github.com/habx/pg-commands"
	_ "github.com/lib/pq"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
	"log"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"
)

const (
	DbName = "talkliketv"
	DbUser = "talkliketv"
	DbPass = "pa55word"
)

const (
	ValidUserId      = 3
	ValidPhraseId    = "2285"
	ValidPhraseIdInt = 2285
	ValidMovieId     = "6"
	ValidMovieIdInt  = 6
	ValidLanguage    = "Spanish"
	ValidLanguageId  = 2
	ValidPassword    = "validPassword"
	TestEmail        = "test@email.com"
	DbCtxTimeout     = 60 * time.Second
)

type TestDatabase struct {
	DbInstance *sql.DB
	DbAddress  string
	container  testcontainers.Container
}

func SetupTestDatabase() *TestDatabase {

	// setup db container
	ctx, cancel := context.WithTimeout(context.Background(), DbCtxTimeout)
	container, db, dbAddr, err := createContainer(ctx)
	if err != nil {
		log.Fatal("failed to setup test", err)
	}

	_, path, _, ok := runtime.Caller(0)
	println("path is : " + path)
	if !ok {
		log.Fatal(err)
	}

	dir, _ := filepath.Split(path)
	fmt.Println("Dir:", dir)

	// migrate db schema
	err = migrateDb(dbAddr)
	if err != nil {
		log.Fatal(err)
	}

	//script, err := os.ReadFile(dir + "/testdata/setup.sql")
	//if err != nil {
	//	log.Fatal(err)
	//}

	splitAddr := strings.Split(dbAddr, ":")
	port, err := strconv.Atoi(splitAddr[1])
	if err != nil {
		log.Fatal(err)
	}
	restore, _ := pg.NewRestore(&pg.Postgres{
		Host:     splitAddr[0],
		Port:     port,
		DB:       DbName,
		Username: DbUser,
		Password: DbPass,
	})

	restoreExec := restore.Exec(dir+"testdata/talkliketv_1705949676.sql.tar.gz", pg.ExecOptions{StreamPrint: false})
	if restoreExec.Error != nil {
		fmt.Println(restoreExec.Error.Err)
		fmt.Println(restoreExec.Output)
		log.Fatal("Restore failure")
	} else {
		fmt.Println("Restore success")
		fmt.Println(restoreExec.Output)

	}
	//_, err = db.Exec(string(script))
	//if err != nil {
	//	log.Fatal(err)
	//}

	if err != nil {
		log.Fatal("failed to perform db migration", err)
	}
	cancel()

	return &TestDatabase{
		container:  container,
		DbInstance: db,
		DbAddress:  dbAddr,
	}
}

func (tdb *TestDatabase) TearDown() {
	tdb.DbInstance.Close()
	// remove test container
	_ = tdb.container.Terminate(context.Background())
}

func createContainer(ctx context.Context) (testcontainers.Container, *sql.DB, string, error) {

	var env = map[string]string{
		"POSTGRES_PASSWORD": DbPass,
		"POSTGRES_USER":     DbUser,
		"POSTGRES_DB":       DbName,
	}
	var port = "5432/tcp"

	req := testcontainers.GenericContainerRequest{
		ContainerRequest: testcontainers.ContainerRequest{
			Image:        "postgres:14-alpine",
			ExposedPorts: []string{port},
			Env:          env,
			WaitingFor:   wait.ForLog("database system is ready to accept connections"),
		},
		Started: true,
	}
	container, err := testcontainers.GenericContainer(ctx, req)
	if err != nil {
		return container, nil, "", fmt.Errorf("failed to start container: %v", err)
	}

	p, err := container.MappedPort(ctx, "5432")
	if err != nil {
		return container, nil, "", fmt.Errorf("failed to get container external port: %v", err)
	}

	log.Println("postgres container ready and running at port: ", p.Port())

	time.Sleep(time.Second)

	dbAddr := fmt.Sprintf("localhost:%s", p.Port())
	db, err := sql.Open("postgres", fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", DbUser, DbPass, dbAddr, DbName))
	if err != nil {
		return container, db, dbAddr, fmt.Errorf("failed to establish database connection: %v", err)
	}

	return container, db, dbAddr, nil
}

func migrateDb(dbAddr string) error {
	databaseURL := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", DbUser, DbPass, dbAddr, DbName)

	err := migrateUp("file://../../../migrations", databaseURL)
	if err != nil {
		return err
	}

	log.Println("migration done")

	return nil
}

func migrateUp(files string, dbURL string) error {
	m, err := migrate.New(fmt.Sprintf("file:%s", files), dbURL)
	if err != nil {
		return err
	}
	defer m.Close()

	err = m.Up()
	if err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return err
	}

	return nil
}
