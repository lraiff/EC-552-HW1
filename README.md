# EC-552-HW1
To obtain the promoter library:
  - download the any of the .input.json from the CELLO github and put in the same folder as the algorithm
  - copy the library into the same file as the circuit design

To obtain the gate library:
  - download the any of the .UCF.json from the CELLO github and put in the same folder as the algorithm

To make a circuit design follow the following format for a .json file:

     "collection": "circuit",
        "outputs": [
            "output_name"
          ],
          "inputs": [
		{
              "name": "input_name1",
		  "table": [ ] //truth table
		},
		{
              "name": "input_name2",
		  "table": [ ] //truth table
		}

        //you can add more promoters, if you desire more inputs
		
          ],
        "design": [
         "NOR(O1,input_name1,input_name2)", //O1 has the value of the output of this gate
         "NOT(output_name,O1)" 

         //you can add as many lines of design as you want, but the output_name must be the output of the last line
        ]


In order to run the algorithm on your design:
    1. Place your .json file containing your design and promoters into the same folder as the algorithm
    2. Run the Code
    3. When the code prompts for a gate, select desired gate.
    4. Enter whether you want any operations to be done to the selected gate
    5. Repeat until you reach the end of the design.
    6. View the text file to view what operations were done on all the gates and the final score of the circuit