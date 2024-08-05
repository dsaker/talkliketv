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

- install golang if needed (https://go.dev/doc/install)
```shell
make build/web
cp ansible/inventory.txt.bak ansible/inventory.txt
cp terraform/terraform.tfvars.bak terraform/terraform.tfvars
```
- create gcp project (https://cloud.google.com/resource-manager/docs/creating-managing-projects)
- create ssh keys if needed (https://cloud.google.com/compute/docs/connect/create-ssh-keys)
```shell
gcloud init
gcloud services enable storage-component.googleapis.com  compute.googleapis.com translate.googleapis.com storage.buckets.getIamPolicy'
```
- create mailtrap account as described above
- get smtp username and password from Email Testing Inbox
- fill in the values for the variables in terraform/terraform.tfvars and ansible/inventory.txt
- also change google_compute_instance.talkliketv.connection.user and private_key to your user values
  - (terraform will not allow you to use vars for provisioners with when = destroy)
- install terraform if needed (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- install anisble if needed (https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)
```shell
terraform init
terraform plan
terraform apply
```
- comment out module.bucket_module from main.tf
- uncomment three resources below it
  - google_storage_bucket_objects.files
  - local_file.initdb_file
  - google_storage_bucket_object_content.initdb
- remove bucket_module from terraform state (you do not want to destroy the bucket or service account)
```shell
terraform state rm module.bucket_module
```
- run `make browser` in root directory to open web application in browser
- Signup user
- get activation code from mailtrap.io and activate account
- Login
- click on Upload
- You can upload scripts/shell/TheMannyS01E01.Spanish.srt.stripped as a test to make sure cloud translate is working
![img.png](readme_images/img.png)
- click on Account > Change Language and choose Spanish
- click on Titles and Select TheMannyS01E01
- you can upload files that end in stripped in scripts/shell or use the stirpsrt script to make your own from srt files
- TheManny is to English from Spanish and MissAdrenaline is from english to any language
- directions for extracting srt files from mkv files are below, or you can upload any txt file with the phrases you want to learn one on each line
- After you upload a new language, it will appear in the Change Language select list 
- select the Title you would like to start learning
- you can also upload a tsv file to the database using the uploadtsv.sh script (the english side of the translation must be the first column)

### Destroying infrastructure using terraform

- you can run `terraform destroy` to destroy the infrastructure and stop incurring charges
- everything except what is in module.bucket_module will be destroyed
- on subsequent `terraform apply` your progress will be loaded from the sql file stored in the bucket
- the backup sql file is created and stored by the "remote-exec" provisioner when terraform destroy is run

### Extract srt file from mkv files

- download mkvextract tool -> https://mkvtoolnix.download/downloads.html
- find srt track of language you would like to extract `mkvinfo mkvfile.mkv` and extract
- `mkvextract mkvfile.mkv tracks 5:[Choose Title].[Choose Language].srt`

### To Do

- add comments
- add text translate tests
- backup db button
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
