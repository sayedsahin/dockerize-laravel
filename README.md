`git clone https://github.com/sayedsahin/dockerize-laravel.git YourFolderName`

cp .env.example .env
make for-linux-env
## For New Project
`make create-project`
`sudo chown -R $USER:$USER src/.env`

## Existing Project
`make build`
`make up`