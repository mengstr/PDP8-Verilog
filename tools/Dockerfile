FROM verilator/verilator:latest AS VERILATOR
FROM cranphin/iverilog:latest AS IVERILOG
FROM cranphin/icestorm:latest AS ICESTORM

FROM cimg/base:2020.01

COPY --from=VERILATOR /usr/local/share/verilator/     /usr/local/share/verilator/
COPY --from=VERILATOR /usr/local/bin/                 /usr/local/bin
COPY --from=IVERILOG  /usr/local/bin/                 /usr/local/bin
COPY --from=IVERILOG  /usr/local/lib/                 /usr/local/lib
COPY --from=ICESTORM  /usr/local/bin/                 /usr/local/bin
COPY --from=ICESTORM  /usr/local/share/arachne-pnr/   /usr/local/share/arachne-pnr/
COPY --from=ICESTORM  /usr/local/share/icebox/        /usr/local/share/icebox/
COPY --from=ICESTORM  /usr/local/share/yosys/         /usr/local/share/yosys/

RUN sudo apt-get update
RUN sudo apt-get -y install libtcl8.6 libboost-python1.65 libboost-filesystem1.65.1 libboost-thread1.65.1 libboost-program-options1.65.1 libqt5widgets5 
RUN sudo apt-get clean
