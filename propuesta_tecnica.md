# Propuesta Técnica y Estrategia de Datos: Unificación Analítica para CaféNorte

**Objetivo:** Consolidar las 3 fuentes de información (POS Tiendas Físicas, ERP Inventarios y Shopify E-Commerce) en una solución analítica unificada, confiable y automatizada en la nube de AWS.

---

## Arquitectura

* _**Amazon S3**_: Almacenamiento plano (Data Lake) para los archivos CSV, Parquet y JSON recibidos (~200 MB/mes) ➡️ $0.30 USD/mes

* _**AWS Lambda**_: Cómputo serverless que ejecuta el script `Python` durante ~1 a 2 minutos cada 30 minutos ➡️ $0.00 USD/mes (Cubierto por la capa gratuita de 400,000 GB-s/mes)

* _**Amazon EventBridge**_: Orquestador cron para disparar la función Lambda automáticamente cada 30 minutos ➡️ $0.00 USD/mes

* _**Amazon RDS PostgreSQL (`db.t4g.medium`)**_: Base de datos relacional administrada con 2 vCPU, 4 GB RAM y 20 GB de almacenamiento SSD ➡️ $52.00 USD/mes

* _**Amazon RDS Automated Backups**_: Respaldos automáticos diarios con punto de restauración y retención de 7 días ➡️ $2.00 USD/mes

* _**AWS Secrets Manager**_: Almacenamiento encriptado de las credenciales de acceso a la base de datos ➡️ $0.40 USD/mes

* _**AWS VPC Interface Endpoint**_: Conexión privada de red para que Lambda acceda a Secrets Manager sin salir a internet ➡️ $7.00 USD/mes

* _**Amazon CloudWatch**_: Registro de logs de la ejecución de Polars, métricas de CPU/Memoria de RDS y alertas por fallo ➡️ $2.50 USD/mes

Costo total: **~$65 USD / Mes**

---

## Plan de implementación

1. _**Infraestructura Base y Base de Datos**_: Despliegue de red privada VPC con AWS VPC Endpoint, credenciales en Secrets Manager y Amazon RDS PostgreSQL

2. _**Pipeline Serverless e Ingesta S3**_: Configuración del bucket en Amazon S3 por carpetas, refactorización del script de Python/Polars para cargas incrementales y empaquetado en AWS Lambda.

3. _**Capa Analítica y Orquestación**_: Creación de vistas analíticas SQL en PostgreSQL, automatización de ejecuciones cada 30 minutos mediante Amazon EventBridge y alertas de errores en Amazon CloudWatch.

4. _**Pruebas e Integración**_: Pruebas de carga con datos sintéticos, validación de integridad referencial en la base de datos y entrega de documentación final en el repositorio.

---

## Supuestos

* _**Estructura y Codificación de Archivos**_: Se asume que todos los archivos tienen la misma estructura, nombres de columnas consistentes y codificación UTF-8.

* _**Volumen y Límite de Cómputo**_: Se asume un volumen promedio de ~600 registros por lote cada 30 minutos, el cual no sobrepasa la memoria asignada (2 GB RAM) ni el límite de tiempo de ejecución de AWS Lambda

* _**Tolerancia a Latencia**_: La solución opera bajo un modelo por lotes (cada 30 minutos), lo cual no rquiere arquitectura de streaming continuo

* _**Permisos de Infraestructura**_: Se asume acceso a una cuenta de AWS con políticas IAM necesarias para aprovisionar RDS, Lambda, S3, Secrets Manager y EventBridge

---

### Preguntas abiertas

* _**Notificación de Errores**_: Ante un fallo en el proceso de ejecución de cualquier de los pasos del pipeline, ¿Qué canal es el preferido para el envío de alertas automáticas?

* _**Ingesta de archivos**_: ¿Cada cuanto tiempo las áreas correspondientes hacen el envío de sus archivos y por qué medio?

* _**Sistema centralizado**_: ¿Se ha pensado en tener algún sistema intermedio que conecte la información de las áreas involucradas?

