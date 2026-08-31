# CaféNorte - Data Solution Pipeline

[![Python Version](https://img.shields.io/badge/python-3.13%2B-blue.svg)](https://www.python.org/)
[![Package Manager](https://img.shields.io/badge/uv-managed-purple.svg)](https://github.com/astral-sh/uv)

> [!NOTE]
> La propuesta técnica al proyecto se encuentra en la raíz del proyecto con nombre [`propuesta_tecnica.md`](./propuesta_tecnica.md) así como el archivo [`AI.LOG.md`](./AI_LOG.md)

Pipeline analítico de ingeniería de datos diseñado para **CaféNorte**. Solución que ingiere, limpia, consolida y modela datos heterogéneos provenientes de tres tipos de archivos origen (parquet, csv y json) hacia una base de datos analítica centralizada en PostgreSQL.

## 🚀 Requisitos Previos e Instalación

Este proyecto utiliza [**`uv`**](https://github.com/astral-sh/uv) como gestor ultrarrápido de paquetes y entornos virtuales de Python.

### 1. Instalación de `uv`

Si no tienes `uv` instalado, puedes instalarlo ejecutando:

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. Clonar el repositorio y sincronizar el entorno

`uv` descargará e instalará automáticamente Python 3.13+ y todas las dependencias requeridas en un entorno virtual aislado:

```bash
git clone <URL_DEL_REPOSITORIO>
cd cafenorte-data-solution

# Sincronizar e instalar todas las dependencias principales y de desarrollo
uv sync --all-groups
```

---

## 📦 Dependencias del Proyecto

El proyecto está configurado bajo la especificación moderna de `pyproject.toml` con las siguientes librerías clave:

### Dependencias Principales (`dependencies`)

* **`polars` (`>=1.44.1`)**: Motor principal de procesamiento de datos en memoria (alto rendimiento y bajo consumo).
* **`adbc-driver-manager` (`>=1.12.0`)**: Conector ADBC (Arrow Database Connectivity) para cargas masivas de ultra alta velocidad hacia PostgreSQL.
* **`pyarrow` (`>=25.0.1`)**: Manejo e interoperabilidad de formatos en memoria y lectura eficiente de archivos `.parquet`.

* **`python-dotenv` (`>=1.2.3`)**: Carga variables de entorno desde un archivo `.env` hacia `os.environ` para gestionar la configuración del proyecto de forma segura.

### Grupo de Desarrollo (`dev`)

* **`ipykernel` (`>=7.3.0`)**: Kernel interactivo para análisis y prototipado mediante Jupyter Notebooks, se usa más para pruebas y visualizacón de la data.

* **`pandas` (`>=3.0.5`)**: Soporte complementario para manipulación de tablas, se usa solamente para visualización de tablas ya que lo requiere la extensión [`Data Wrangler`](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.datawrangler) para `VSCode`.

---

## 🛠️ Herramientas de Consola y Ejecución

### Ejecución de herramientas `dbc` con `uv`

Para ejecutar utilidades o herramientas de base de datos/interfaz mediante la suite `dbc` a través del gestor de herramientas globales de `uv`, utiliza los siguientes comandos para instalar y utilizar `PostgreSQL`, que es el motor utilizado para este proyecto:

```bash
uv tool run dbc init
uv tool run dbc add postgresql
uv tool run sync
```

---

## 🏃‍♂️ Cómo Iniciar y Ejecutar el Pipeline

### Línea de comandos `uv`

Para ejecutar la **demo**, ejecuta en la terminal:

```bash
uv run demo
```

De esta manera se ejecutará todo el pipeline y se crearan los esquemas y tablas, también se cargarán los datos en la base de datos previamente creada (base de datos y usuario)

---

## ⚙️ Configuración de la Base de Datos

> [!NOTE]
> Tanto la base de datos como el usuario deben ser creados previamente, ya que automatizar esto requiere mejor configuración por temas de seguridad

Asegúrate de contar con una instancia de **PostgreSQL** (local o en Amazon RDS) configurada con las credenciales de acceso en las variables de entorno o archivo de configuración `.env`:

```env
USER_DB_CAFENORTE=usr_example
PASSWD_DB_CAFENORTE=passwd_example123
NAME_DB_CAFENORTE=name_db_example
```

---

## ❓ Preguntas ambiguas

1. _**Top 10 SKUs por rotación**_: No se especifica la unidad re rotación ya que la misma puede responde
rse en dinero (finanzas) o unidades (operaciones), se calcula en base a las unidades.

2. _**Tiendas con quiebres de stock > 3 días**_: No se menciona si deben ser días consecutivos o acumulados a lo largo del trimestre, se calcula en base a días consecutivos.
