# fpga_a7-lite_hdmi

This is an HDMI output example for MicroPhase A7-Lite FPGA board with an XC7A100T (Artix-7) FPGA.

![main](https://github.com/user-attachments/assets/7635294e-d5ae-4a0c-ae29-7b581cc55e74)

When creating a Vivado project, please select **xc7a100tfgg484-1** as an FPGA.

Using Clocking Wizard of Vivado, please create an IP that inputs a 50MHz clock signal and outputs 25MHz and 250MHz clock signals.

![clock](https://github.com/user-attachments/assets/1858ca75-f1cc-4d95-a771-6891c947630f)

The HDMI display shows the following pattern.

https://github.com/user-attachments/assets/97278351-a91e-49ef-a9b1-7a2c3b1cfb9f

This table shows the hardware utilization of post-implementation. 

![resource](https://github.com/user-attachments/assets/6d40fc8c-a137-4d6c-b6df-e44bf661860f)
