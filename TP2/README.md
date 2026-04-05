# [TRABAJO PRÁCTICO N° 2 ~ Electronica Digital II]

## 📖 Descripción General


---

## ⚙️ ¿Cómo funciona? (Explicación Detallada)
El código está desarrollado en lenguaje Ensamblador (Assembly) para el microcontrolador **PIC16F887** y su flujo de ejecución principal se divide en las siguientes etapas:

1. **Inicialización y Configuración (Macros):**
   * El programa comienza definiendo la configuración del hardware (fusibles) y reservando espacio en memoria (`CBLOCK 0x20`) para los contadores de retardo y repeticiones.
   * Utiliza macros (`CFG_LEDS`, `CFG_SWITCH`) para configurar los registros: establece el Puerto D (`PORTD`) completo como salida digital para controlar los LEDs y el pin 0 del Puerto E (`RE0`) como entrada digital para leer el estado de un pulsador.
   * Se inicializan los valores base para los temporizadores mediante las macros `CFG_DELAY`.

2. **Bucle Principal de Lectura (Polling):**
   * El sistema entra en una etiqueta llamada `LOOP` donde interroga constantemente el estado del pin `RE0` (`BTFSC PORTE, RE0`).
   * Dependiendo del estado del pulsador, el programa diverge en dos caminos principales:
     * **Si está suelto (1 lógico):** Salta a `MODO_BLINK`.
     * **Si está presionado (0 lógico):** Salta a `MODO_SECUENCIA`.

3. **Modos de Iluminación:**
   * **MODO_BLINK:** Enciende todos los LEDs del Puerto D simultáneamente, espera 1 segundo mediante una subrutina de retardo (`DELAY_1s`), los apaga, espera otro segundo y vuelve a consultar el botón.
   * **MODO_SECUENCIA:** Ejecuta de forma automática tres patrones visuales distintos. Utiliza registros como `CONT_RL` para repetir cada patrón exactamente 3 veces antes de pasar al siguiente:
     * *Running Light (`BLINK_RL`):* Un solo LED se desplaza de RD0 a RD7 con retardos de 300ms.
     * *Bidirectional Running Light (`BLINK_BRL`):* El LED hace un barrido de ida (RD0 a RD7) y vuelta (RD6 a RD1) como el "Auto Fantástico", con retardos de 200ms.
     * *Crawling (`BLINK_CRAW`):* Efecto de arrastre o llenado; los LEDs se van encendiendo uno por uno (acumulándose de RD0 a RD7) con retardos de 100ms, para luego apagarse todos y reiniciar.

4. **Subrutinas de Temporización (Delays):**
   * El código incluye retardos precisos de 1s, 300ms, 200ms y 100ms. Estos se logran utilizando bucles anidados (`LOOP1`, `LOOP2`, `LOOP3`, etc.) que decrementan variables previamente cargadas (`DECFSZ`) consumiendo ciclos de instrucción (ciclos máquina) exactos para generar la pausa deseada antes de continuar.

---

## 🛠️ Tecnologías Utilizadas
* **Microcontrolador:** PIC16F887
* **Lenguaje:** Ensamblador (Assembly - MPASM)
* **Entorno de Desarrollo:** MPLAB X IDE
* **Arquitectura de retardo:** Temporización por software (bucles anidados `DECFSZ`)

---

## 🧪 Pruebas End-to-End (E2E)
<img width="766" height="457" alt="image" src="https://github.com/user-attachments/assets/7a502343-6896-44c9-a897-dae938658f3e" />

<video src="./Docs/TP2_circutio - Proteus 8 Professional - Schematic Capture 2026-04-05 15-11-53.mp4" controls="controls" width="100%">
</video>



