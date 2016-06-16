# primaryinjection

This project is based on Transpower's standard transformer protection design. It assumes that CTs are starred towards the protected object and have a 1 A secondary.

It is to help check whether or not:
* local service voltage (415V 3-ph in New Zealand) is able to produce an appropriate amount of differential current as seen by the secondary relay
* how this varies with transformer size, MVA and impedance

In general it is thought that for relays like the Siemens 7UT613 that around 20 mA (2% rated secondary current) is required for positive confirmation of overall differential stability via three phase injection.

## Installation and use:

* Ensure you have a login to [SageMathCloud](https://cloud.sagemath.com)
* Load the files in this repository to a new project
* Open the ```.sagews``` worksheet
* Run all cells by selecting the text inside the worksheet window (click somewhere), select all (Ctrl+A) and run all cells (Ctrl+Shift+Enter)
* At bottom of the worksheet a display will allow you to choose parameters. After selecting them, the picture will update

## How it works:
* There is just a simple base [```.svg```](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) file which is just an XML document
* Per unit calculations are shown and the svg is modified and then displayed to the user
* There is a function for displaying numbers in engineering/SI units
* [Decorators](http://simeonfranklin.com/blog/2012/jul/1/python-decorators-in-12-steps/) are used with [interacts](http://doc.sagemath.org/html/en/prep/Quickstarts/Interact.html)

## How to contribute
* Pull requests and issues in Github please