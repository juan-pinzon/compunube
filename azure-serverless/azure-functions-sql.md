# Práctica Azure SQL

## A) Creación de la Base de datos
Para ello podemos seguir la guía que nos brinda la documentación propia de Azure [Create a single database - Azure SQL Database | Microsoft Docs](https://docs.microsoft.com/es-es/azure/azure-sql/database/single-database-create-quickstart?tabs=azure-portal#code-try-3) 
En este caso utilizaremos un grupo de recursos existente, que hemos llamado **"compunubeRG"** . El nombre de la Base de datos será **"compunubeDB"**. Como Debemos crear un servidor para la BD el nombre de este será **"compunube-server-db"**. Además utilizaremos la autenticación SQL normal (user & pass) que será: *admindb* como usuario y *compunubeDB22_* como contraseña.
## B) Crear Azure Function
Para esto también podemos seguir la guía que nos ofrece la documentación, en este caso con el lenguaje C#.
[Creación de una función de C# desde la línea de comandos: Azure Functions | Microsoft Docs](https://docs.microsoft.com/es-es/azure/azure-functions/create-first-function-cli-csharp?tabs=azure-cli%2Cin-process)
Crearemos un proyecto de forma local en nuestra máquina vagrant con el nombre de **compunubeFuncSqlProj**. Dentro de ese proyecto crearemos una función con el nombre de **HttpCompunube**, con el siguiente comando como lo indica la guía:
```bash
func new --name HttpCompunube --template "HTTP trigger" --authlevel "anonymous"
```
Hacemos una copia del archivo original de HttpCompunube.cs para tenerlo como respaldo, para luego reemplazar el original con el siguiente código:
```csharp
using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace compunubeFuncSqlProj
{
	public static class HttpCompunube
	{
	
		[FunctionName("ProductCategory")]
		public static async Task<IActionResult> Run(
			[HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req, ILogger log)
		{
			log.LogInformation("C# HTTP trigger function processed a request.");
			string name = req.Query["name"];

			var str = "Server=tcp:compunube-server-db.database.windows.net,1433;Initial Catalog=compunubeDB;Persist Security Info=False;User ID=admindb;Password=compunubeDB22_;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

			var res = new List<string>();
			using (SqlConnection conn = new SqlConnection(str))
			{
				conn.Open();
				var text = "select name from [SalesLT].[ProductCategory];";
				using (SqlCommand cmd = new SqlCommand(text, conn))
				{
					SqlDataReader reader = cmd.ExecuteReader();
					if (reader.HasRows)
					{
						while (reader.Read())
						{
							res.Add(reader.GetString(0));
						}
					}
					reader.Close();
					conn.Close();
				}
			}
			return new OkObjectResult(res);	
		}
	}
}
```
Para este caso crearemos todo un grupo de recursos y demás para publicar la function

Creación del grupo de recursos:
```bash
az group create --name AzureFunctionsQuickstart-rg  --location australiacentral
```
Creación de una cuenta de almacenamiento de uso general en su grupo de recursos y región
```bash
az storage account create --name  compunubestorage  --location  australiacentral  --resource-group AzureFunctionsQuickstart-rg  --sku Standard_LRS
```
Por último creamos la function con los recursos creados anteriormente
```bash
az functionapp create --resource-group AzureFunctionsQuickstart-rg --consumption-plan-location  australiacentral --runtime dotnet --functions-version 3 --name  compunubeAzuFuncSql --storage-account compunubestorage
```
Recordemos que para publicar nuestra función debemos tener ya un grupo de recursos, en este caso también tenemos ya una function, por lo que será solo actualizarla con 
```bash
 func azure functionapp publish compunubeAzuFuncSql
```
https://compunubeazufuncsql.azurewebsites.net/api/productcategory
