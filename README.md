# Mi Tiendita PoS

~~(Sí, ese nombre le puse, que les valga madre.)~~

## ¿Que es esto?

Pretende ser un punto de venta sencillo y portable, que ocupe mucho menos
espacio que el que requeriría un punto de venta tradicional, ya sabes, la típica
computadora con su monitor, regulador y teclado; cosas que no podrías tener en
lugares abarrotados... Cómo una tienda de abarrotes, este punto de venta no
pretende ser utilizado en negocios enormes como MallMart o SoyRiana (nombre
alterados para evitar Copyright, sabes bien a quienes me refiero ;-) )

La primera fase del proyecto ya está lista y cumple con lo básico de una CRUD
Basada en SQLite.

## ¿Que tenemos hecho?

Entre las cosas que actualmente es capaz de hacer están:

- La creación automática de una base de datos con una tabla de inventario, una
tabla de ventas realizadas y probablemente después agregue más tablas.
- Las acciones fundamentales de Una CRUD para insertar productos en el
inventario, eliminarlos y modificarlos.
- Capacidad para escanear códigos de barras usando la cámara del celular.
- Una pantalla de ventas que incluye la venta de productos a granel.
- un historial de ventas para auditorías y análisis (muy básica aún.)

## Se vienen cositas (¿Que estamos haciendo ahora?)

Dado que somos consientes de que escanear códigos de barras constantemente con
la cámara del celular puede resultar tedioso para algunas personas (y hasta
arriesgar dicha pieza de patrimonio) nos encontramos trabajando en la segunda
fase del proyecto, la cual trata de integrar un escáner externo, conectado por
BLE, con los siguientes objetivos:

- Evitar el uso constante de la cámara del celular para escanear los códigos de
  barras.
- Realizar las operaciones CRUD en segundo plano, aún sí el celular está
bloqueado, eso evitará la necesidad de tener el dispositivo encendido y
desbloqueado todo el tiempo, ahorrando batería y haciendo más
eficiente el flujo de trabajo.
- Mostrar en una pantalla montada en el dispositivo el monto actual de la venta
  y el precio de los productos escaneados.

A Grandes rasgos esos puntos responden al "¿Qué?" buscamos lograr, y me veo en
la necesidad de explicar el "¿Cómo?"

Diseñaremos nuestro propio dispositivo basándonos en el módulo GM65 y un ESP32,
el firmware de ese dispositivo eventualmente será subido a su propio
repositorio, los esquemáticos y los archivos CAD de la carcasa quizá los suba
a mi Portafolio.
