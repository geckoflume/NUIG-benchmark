# NUIG-benchmark

Supervised learning project at NUI Galway IT department to predict the behaviour of web applications under heavy load by knowing server raw performance (CPU score, RAM score and I/O score).

## Performance benchmarks
### [Phoronix Test Suite](https://www.phoronix-test-suite.com/)
The most popular benchmarking suite available for Linux.
Large data collection available on http://openbenchmarking.org/.

## Web applications
### [RUBBoS](http://jmob.ow2.org/rubbos.html)
A bulletin board benchmark modeled after an online news forum like Slashdot.
We are here using [@michaelmior](https://github.com/michaelmior) implementation (https://github.com/michaelmior/RUBBoS).

### [RUBiS](http://rubis.ow2.org)
An auction site benchmark prototype modeled after eBay.com.

### [TPC-W](http://jmob.ow2.org/tpcw.html)
A standard benchmark that models an online bookstore.
We are here using [@jopereira](https://github.com/jopereira) implementation (https://github.com/jopereira/java-tpcw/tree/uminho).

## Installation
The *install* option of the scripts will setup the required dependencies, clone and configure the applications, ready to run.

    git clone https://github.com/geckoflume/NUIG-benchmark
    cd NUIG-benchmark
    sudo ./script-rubbos.sh install
    sudo ./script-rubis.sh install
    sudo ./script-tpcw.sh install

## Run
The *run* option of the scripts will execute the benchmarks.

    sudo ./script-rubbos.sh run
    sudo ./script-rubis.sh run
    sudo ./script-tpcw.sh run
 
## More info

Scripts tested for Ubuntu 14.04 LTS amd64.