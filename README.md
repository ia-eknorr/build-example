# Common Docker Image for Ignition

## Purpose

The purpose of this image is to provide a quick way to spin up docker containers that include some necessary creature comforts for version control, theme management, custom environment variables, and easy interaction with the required file system components for an Ignition gateway.

This image is automatically built for versions 8.1.25-8.1.42. New versions will be updated, but any features are subject to change with later versions.

If using a Windows device, you will want to [Set up WSL](https://github.com/ia-eknorr/ignition-version-control/blob/main/Set%20Up%20WSL.md)

___

## Reference Docs

* [Git Style Guide](https://github.com/ia-eknorr/ignition-git-style-guide)
* [IA Version Control Documentation](https://github.com/ia-eknorr/ignition-version-control)

## Requirements

* [Proper workstation setup](https://github.com/ia-eknorr/ignition-version-control/blob/main/Workstation%20Setup.md)
  * Git
  * Github CLI
  * Visual Studio Code
  * WSL (Windows only)
* Docker

## Getting the Docker Image

When pulling the docker image, note that using the copy link from the home page (`docker pull etknorr/common-docker-ignition`) will automatically pull the most recent version of Ignition configured in the image. For example `:latest` may pull version `8.1.44` as of the time of writing.

## File Access

This custom build creates a symlink in the `/workdir` directory to a few of the components in Ignition's `data` directory. This allows you to easily access the files on the host system, and simplifies the necessary `.gitignore` for a project. The following items are symlinked by default, and these are the environment variables that enable them:

| Symlink Path | Environment Variable |
| --- | --- |
| `/usr/local/bin/ignition/data/projects` | `SYMLINK_PROJECTS` |
| `/usr/local/bin/ignition/data/modules` | `SYMLINK_THEMES` |

To disable one of the symlinks, set the environment variable to `false`. For example, to disable the symlink to the `projects` directory, set `SYMLINK_PROJECTS=false`

### Note for Windows/Linux Users

In order for the symlinks to work, you must first create an empty folder adjacent to the `docker-compose.yml` file that has the same name as the desired bind mount. On Windows/Linux docker will automatically do everything as `root`, so without doing this the created file will be owned by `root:root` instead of `user:user`. On a Mac, this is not necessary, MacOS ftw.

___

## Customizations

This is a derived image of the `inductiveautomation/ignition` image. Please see the [Ignition Docker Hub](https://hub.docker.com/r/inductiveautomation/ignition) for more information on the base image. This image should be able to take all arguments provided by the base image, but has not been tested.

### Environment Variables

This image also preloads the following environment variables by default:

| Environment Variable           | Min-Version | Value                             								  |
| ------------------------------ | ----------- | -----------------------------------------------------------------|
| `ACCEPT_IGNITION_EULA`         | 8.1.13      | `Y`                               								  |
| `GATEWAY_ADMIN_USERNAME`       | 8.1.13      | `admin`														  |
| `GATEWAY_ADMIN_PASSWORD`       | 8.1.13      | `seteamdevserver` 												  |
| `IGNITION_EDITION`             | 8.1.13      | `standard`                            							  |
| `IGNITION_UID`                 | 8.1.13      | `1000`                                							  |
| `IGNITION_GID`                 | 8.1.13      | `1000`                                							  |
| `PROJECT_SCAN_FREQUENCY`       | 8.1.13      | `10`                                  							  |
| `SYMLINK_PROJECTS`             | 8.1.13      | `true`                                							  |
| `SYMLINK_THEMES`               | 8.1.13      | `true`                                							  |
| `DEVELOPER_MODE`               | 8.1.13      | `N`                                   							  |
| `DISABLE_QUICKSTART`           | 8.1.23      | `true`                                							  |
| `DEVELOPER_MODE`               | 8.1.13      | `N`                                                              |
| `DISABLE_QUICKSTART`           | 8.1.23      | `true`                                                           |
| `GATEWAY_ENCODING_KEY`         | 8.1.38      | If not set, will be generated for password injection to the db.  |
| `GATEWAY_ENCODING_KEY_FILE`    | 8.1.38      | If not set, will be generated for password injection to the db.  |
| `SYSTEM_USER_SOURCE`           | 8.1.13      | `""`                                                             |
| `SYSTEM_IDENTITY_PROVIDER`     | 8.1.13      | `""`                   										  |
| `HOMEPAGE_URL`                 | 8.1.13      | `""`                   										  |
| `DESIGNER_AUTH_STRATEGY`       | 8.1.13      | `""`                   										  |
| `CONFIG_PERMISSIONS`           | 8.1.13      | `"Authenticated/Roles/Administrator"`, See [Permission Syntax](#permission-syntax) for help.      |
| `STATUS_PAGE_PERMISSIONS`      | 8.1.13      | `"Authenticated/Roles/Administrator"`, See [Permission Syntax](#permission-syntax) for help.      |
| `HOME_PAGE_PERMISSIONS`        | 8.1.13      | `""`, See [Permission Syntax](#permission-syntax) for help.      |
| `DESIGNER_PERMISSIONS`         | 8.1.13      | `"Authenticated/Roles/Administrator"`, See [Permission Syntax](#permission-syntax) for help.      |
| `PROJECT_CREATION_PERMISSIONS` | 8.1.13      | `"Authenticated/Roles/Administrator"`, See [Permission Syntax](#permission-syntax) for help.      |

### Permission Syntax

The permissions are a comma separated list of permissions that can be set for the corresponding property. The permission start with the permission type, followed by a comma, and then the permission values in a comma separated list. For example, to set the `CONFIG_PERMISSIONS` value to `Authenticated/Role/Administrator` AND also `Authenticated/Role/Developer`, you would set the `CONFIG_PERMISSIONS` environment variable to `AllOf,Authenticated/Role/Administrator,Authenticated/Role/Developer`.

### Additional Config Folders

Added an environment variable that allows the user to map application config files located in the `data` directory into the `/workdir`. This is customized by providing a comma separated list of folders in a string to the environment variable. For example, to map the `data/notifications` and `data/configs` folders, set the environment variable `ADDITIONAL_DATA_FOLDERS=notifications,configs` to the `docker-compose.yml` file.

### Third Party Modules

Any additional modules outside of the native ignition ones that want to be added can be mapped into the `/modules` folder in the container. This is done by adding the following to the `volumes` section of the `docker-compose.yml` file:

```yaml
volumes:
	- ./my-local-modules:/modules
```

Due to the way module onboarding works, in order for it to take effect, you must restart the container after its initial creation. This can be done by running `docker-compose restart` from the directory containing the `docker-compose.yml` file.

### Database Connections

> [!NOTE]
> Requires version 8.1.38 or later, due to the need for the `GATEWAY_ENCODING_KEY` environment variable.

Database connections can be added by mapping in the SQL files to the `/init-db-connections` folder in the container. 

Each database connection should be in a separate `.json` file. The docker entrypoint will scan the `/init-db-connections` folder for `.json` files and use the information to create or update the database connections in the Ignition Gateway. Connections found in the gwbk but not in the `.json` files will be set to disabled. Although the name of the file does not matter, it is recommended to use the name of the connection as the file name. e.g. `ExamplePostgres.json`.

A gateway with multiple connections might be defined like this:

```text
init-db-connections/
├── ExamplePostgres.json
├── DbConnection2.json
└── DbConnection2.json
```

Where each file would have the following structure:

```json
{
  "name": "ExamplePostgres",
  "type": "POSTGRES",
  "description": "Example PostgreSQL Server Connection",
  "connect_url": "jdbc:postgresql://localhost:5432/database",
  "username": "${DB_USERNAME}",
  "password": "${DB_PASSWORD}",
  "connection_props": ""
}
```

Accepted values for `type` are: `MSSQL`, `POSTGRES`, `SQLITE`, `MYSQL`, `ORACLE`, `MARIADB` 

This functionality will either insert or update existing database connections based off the name of the connection.

#### Environment Variables

Environment variables can be used in the `.json` files to inject secrets into the database connection. Any variables used in these json files must be set in the `docker-compose.yml` file. There is no restriction on the name of the variables, but must be in the format `${VARIABLE_NAME}` or `$VARIABLE_NAME` in order to be substituted properly.

### Localization

Localization files can be added by mapping in the localization files to the `/localization` folder in the container. The script supports the native `.properties` and `.xml` export file formats for localization.

> [!WARNING]
> There is a known bug in the parsing of `.properties` files. This bug is being tracked and will be fixed in a future release. Until then, it is recommended to use the `.xml` format for localization files.

#### Properties File Format

For `.properties` files, use the following format:

```properties
#Locale: es
hello=hola
car=coche
```

The first line must specify the locale using `#Locale: <locale_code>`.

#### XML File Format

For `.xml` files, use the following format:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Locale: es</comment>
<entry key="hello">hola</entry>
<entry key="car">coche</entry>
</properties>
```

The `<comment>` tag must specify the locale using `Locale: <locale_code>`.

#### Localization Settings

You can customize the localization settings by creating a `properties.json` file in the `/localization` folder. The file should have the following structure:

```json
{
	"caseInsensitive": false,
	"ignoreWhitespace": false,
	"ignorePunctuation": false,
	"ignoreTags": false
}
```

All fields are optional and default to `false` if not specified.

#### Usage

To use the localization feature:

1. Create a folder named `localization` in your project directory.
2. Add your `.properties` and/or `.xml` localization files to this folder.
3. Optionally, add a `properties.json` file to customize localization settings.
4. In your `docker-compose.yml` file, add a volume mapping for the localization folder:

```yaml
volumes:
  - ./localization:/localization
```

The localization files will be processed when the container starts, and the translations will be available in your Ignition projects.

___

### Example docker-compose file

```yaml
services:
  gateway:
	image: etknorr/ignition-docker:8.1.
    # In order to use this volume, you must first create the directory `data-folder` next to the docker-compose.yml file
    volumes: []
      # - ./data-folder:/workdir
      # - ./my-local-modules:/modules
      # - ./init-db-connections:/init-db-connections
      # - ./idb-images:/idb-images
      # - ./localization:/localization
    environment: []
      # - GATEWAY_ADMIN_USERNAME=admin
      # - GATEWAY_ADMIN_PASSWORD=seteamdevserver
      # - PROJECT_SCAN_FREQUENCY=10
      # - SYMLINK_PROJECTS=true
      # - SYMLINK_THEMES=true
      # - DEVELOPER_MODE=N
      # - HOMEPAGE_URL=""
      # - CONFIG_PERMISSIONS=AllOf,Authenticated/Roles/Administrator,Authenticated/Roles/Developer
      # - STATUS_PAGE_PERMISSIONS=AllOf,Authenticated/Roles/Administrator,Authenticated/Roles/Developer
      # - HOME_PAGE_PERMISSIONS=""
      # - DESIGNER_PERMISSIONS=AllOf,Authenticated/Roles/Administrator,Authenticated/Roles/Developer
      # - PROJECT_CREATION_PERMISSIONS=AllOf,Authenticated/Roles/Administrator,Authenticated/Roles/Developer
      # - ADDITIONAL_DATA_FOLDERS=configs
```

___

### Contributing

This repository uses [pre-commit](https://pre-commit.com/) to enforce code style. To install the pre-commit hooks, run `pre-commit install` from the root of the repository. This will run the hooks on every commit. If you would like to run the hooks manually, run `pre-commit run --all-files` from the root of the repository.

### Local Feature Testing

In order to test your features, you can use the following procedure to build and run your own images. If you aren't familiar with Docker buildx, you can find more information in the [Docker Buildx Guide](https://github.com/inductive-automation/docs-common/blob/main/docs/docker-buildx-guide.md).

1. Clone or fork this repository.
2. Navigate to the directory containing both `Dockerfile` and the `docker-bake.hcl`
3. Run `docker buildx bake --push -t <your-image-name> .`
4. In a new directory, make a `docker-compose.yml` file using the Example docker-compose file above substituting the value for `image` for `<your-image-name>`. See example below:

	```yaml
	services:
	  gateway:
		image: <your-image-name>

	```

### Building a pushing a specific version

1. Open a terminal or command prompt on your host machine.
2. Navigate to the directory containing both `Dockerfile` and the `docker-bake.hcl`
3. Run `docker buildx bake --file ./docker-bake.hcl <build-target> --push`

### Requests

If you have any requests for additional features, please feel free to [open an issue](https://github.com/inductive-automation/common-docker-ignition/issues/new/choose) or submit a pull request.

### Shoutout

Shoutout to [Design Group](https://github.com/design-group) for doing all the hard work on this image, and allowing SE to use it as a base for our own image.

