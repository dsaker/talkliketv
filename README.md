# talkliketv

TalkLikeTV is a language learning application designed to address the shortcomings of other language apps by incorporating authentic native speakers conversing at real speeds and tones.

The unique approach involves learning from the subtitles of TV shows and then watching the episodes at your convenience. By translating from your native language to the spoken subtitles of a TV show, you not only grasp how native speakers communicate but also enhance your ability to understand the dialogue of the show.

You can use a tab separated file to upload any phrases you want to learn using the bash script `./scripts/shell/uploadtsv.sh`. 

The books [Let's Go](https://lets-go.alexedwards.net/) and [Let's Go Further](https://lets-go-further.alexedwards.net/) were used heavily in creating this application. I would highly recommend them to anyone wanting to learn Golang.

### Make

To list available make commands

`make help`

### Create Mailtrap account

- Create an account at [Mailtrap](https://mailtrap.io/)
- Create an inbox in [Email Testing](https://mailtrap.io/inboxes)
- Run `cp .envrc.default .envrc`
- Copy the username and password into SMTP_USERNAME and SMTP_PASSWORD in .envrc

### Startup Locally

- Create Mailtrap account as described above
```
docker pull postgres
docker run -d -P -p 127.0.0.1:5433:5432 -e POSTGRES_PASSWORD="password" --name talkliketvpg postgres
echo "export TALKTV_DB_DSN=postgresql://postgres:password@localhost:5433/postgres?sslmode=disable" >> .envrc
make db/migrations/up
make run/web
make run/api
```

### Build

To build the web application
```
make build/web
```

To build the api
```
make build/api
```

### Deploy web application to google cloud platform

```
cd terraform
cp terraform.tfvars.bak terraform.tfvars
```
- create gcp project (https://cloud.google.com/resource-manager/docs/creating-managing-projects)
- create ssh keys if needed (https://cloud.google.com/compute/docs/connect/create-ssh-keys)
- fill in the values for the variables in terraform.tfvars
- install terraform if needed (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
```
terraform init
terraform apply
```
- note ip output from terraform (you can also run `terraform output` at any time to obtain this value)
- create mailtrap account as describe above
- get smtp username and password from Email Testing Inbox
```
cd ..
make build/web
cd ansible
cp inventory.txt.bak inventory.txt
```
- fill in the needed values <>
- install anisble if needed (https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)
```
ansible-playbook -i inventory.txt playbook.yml
```
- go to https://{{ terraform output ip }}.sslip.io
- signup user
- get activation code from mailtrap.io and activate account
- you can upload files that end in stripped in scripts/shell or use the stirpsrt script to make your own
- TheManny is to English from Spanish and MissAdrenaline is from english to any language
- directions for extracting srt files from mkv files are below, or you can upload any txt file with the phrases you want to learn one on each line
- after uploading a file click on Account > Change language and choose your language
- select the Title you would like to start learning

### Extract srt file from mkv files

download mkvextract tool -> https://mkvtoolnix.download/downloads.html

find srt track of language you would like to extract 
`mkvinfo mkvfile.mkv`
and extract
`mkvextract mkvfile.mkv tracks 5:[Choose Title].[Choose Language].srt`

### To Do

- add comments
- add text translate tests
- openapi3 spec (Huma)
- add observability and monitoring
- use gmail for smtp
- create native and learning lang
- GetAllMovies when not signed in
- delete account
- password reset web

### Setup Google Cloud Translate

https://cloud.google.com/translate/docs/setup
https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev
https://cloud.google.com/docs/authentication/provide-credentials-adc#attached-sa
