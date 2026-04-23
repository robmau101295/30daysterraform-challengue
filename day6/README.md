
# 📅 DAY 6

## 📚 TAREA 1: Book Terraform: Up & Running by Yevgeniy Brikman — Chapter 3, pages 81–113

Read all three sections carefully:

- 👉 What is Terraform State?
  
  Terraform necesita memoria, esa memoria es el "state."
  Sin el state no sabría que creó, que recursos existen o que atributos tienen. No sabría que cambiar en el siguiente plan o apply.

  Terraform consulta al state como un mapa interno para relacionar tu código main.tf con la nube o el provider en el que estás desplegando.

- 👉 Shared Storage for State Files

  ¿Por qué el state local es un problema?

  Cuando trabajos solo, puede ser suficiente. Pero cuando trabajas en equipo pueden existir muchos problemas:

  1. concurrent runs: Cuando dos presonas ejecutan terraform al mismo tiempo sobre la misma infraestructura. (Podrían sobreescribir los cambios del otro y el state queda inconsistente). Por eso es necesario proteger el state contra escirturas simultaneas mediante locking.

  2. lost state: Cuando se pierde el archivo en la máquina local. Ejemplo: Se daño la laptop, borrado accidental, no había versionado o cambio de equipo. Si pierdes el state terraform pierde la memoria.
   
  3. secrets in plain text: El state puede contener secretos en plaintext, por eso se debe almacenar en un backend seguro y controlado.

La solución para evitar estos problemas es usar un almacenamiento compartido o remoto.

Ejemplos comunes de backend:

1. Amazon S3
2. Azure Blob Storage
3. Google Cloud Storage
4. Terraform Cloud / HCP Terraform

Todo el equipo usará el mismo state.

En muchos backends remotos se puede bloquear el state mientras el apply está en ejecución.

Un ejemplo en S3 de Amazon:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}
```

**LA IMPORTANCIA DEL LOCKING**

Se debe evitar que dos personas modifiquen el archivo a la vez. Esto es posible con STATE LOCKING.

Cuando se ejecuta un apply terraform bloquea temporalmente el state.

**EL EJEMPLO EN EL LIBRO ES: AWS S3 + DynamoDB**
S3 para guardar el state
DynamoDB para locking

- 👉 Managing State Across Teams

¿Cómo organizas el state cuando varios personas y varios componentes usan terraform?

No es conveniente manejar un solo state gigante.
Se debe separar state por componentes o entornos.

La recomendacion es dividir:

  - networking
  - database
  - services
  - monitoring

E incluso se puede dividir por entorno:

  - dev
  - stage 
  - prod

Y cada conjunto debe tener su propio state.

**MODULOS**

El Remote state sharing entre módulos/configuraciones es necesario cuando se quiere usar datos de otra configuración.

Se pueden usar modulos y llamar a los outputs para leerlos desde el state remoto.

Ejemplo:

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}
```

Y luego llamas al output de esta manera:

```hcl
subnet_id = data.terraform_remote_state.network.outputs.subnet_id
```

## 📚 TAREA 2. Deploy Infrastructure and Inspect the State File

Para este ejemplo usaré el código del dia 3. Copias el main.tf y haces un terraform init, plan, apply and finally destroy.

Luego de esto, respondes las siguientes preguntas:

What does Terraform store about each resource?
Where are the resource attributes, IDs, and dependencies recorded?
What happens to the state file after terraform destroy?

## 📚 TAREA 3. Configure Remote State Storage with S3 and DynamoDB

