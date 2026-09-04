# TFG — Simulador para prácticas de laboratorio de bromatología

Simulador interactivo de prácticas de laboratorio desarrollado en **Godot**, que guía al usuario paso a paso por el procedimiento experimental, validando cada acción sobre la marcha y señalando los errores cometidos.

## 🖥️ Versiones disponibles

El proyecto se distribuye en dos versiones, correspondientes a los dos métodos de renderizado de Godot:

| Versión | Carpeta | Descripción |
|---|---|---|
| **Forward+** | [`simulador-forward/`](./simulador-forward) | Mejor calidad gráfica. Pensada para ejecución local. |
| **Compatibility** | [`simulador-compatibility/`](./simulador-compatibility) | Necesaria para poder exportar el simulador a web. Calidad gráfica reducida frente a la Forward+. |

Ambas carpetas contienen el mismo código; las únicas diferencias entre ellas son:

- Los **materiales** y la **iluminación** del escenario, adaptados a cada renderizador.
- Las diferencias propias entre los métodos de renderizado **Forward+** y **Compatibility** de Godot.

## ⬇️ Descarga y ejecución local (mejor calidad)

Para disfrutar de la mejor calidad gráfica (versión Forward+), descarga el ejecutable directamente desde la release:

- 🪟 **Windows** → [Descargar Laboratorio.exe](https://github.com/lorena47/TFG/releases/download/v1.0/Laboratorio.exe)
- 🐧 **Linux** → [Descargar Laboratorio.x86_64](https://github.com/lorena47/TFG/releases/download/v1.0/Laboratorio.x86_64)

Al pulsar cualquiera de los enlaces anteriores, la descarga se iniciará automáticamente.

## 🌐 Prueba en el navegador (sin descargas)

Para no descargar nada, prueba la versión Compatibility directamente desde el navegador:

👉 **[Probar la versión web](https://lorenacasfer.itch.io/laboratorio)**

## 🧱 Modelos 3D

Todos los modelos utilizados en el escenario se encuentran en la carpeta [`blend/`](./blend), clasificados según su origen:

- [`blend/hechos/`](./blend/hechos) — Modelos **hechos**: creados por completo desde cero.
- [`blend/extraidos/`](./blend/extraidos) — Modelos **extraídos**: extracción y modificación de objetos procedentes de un modelo de laboratorio de terceros de mayor tamaño.
- [`blend/importados/`](./blend/importados) — Modelos **importados**: modelos de terceros modificados pero usados de forma completa (sin extracción parcial).
