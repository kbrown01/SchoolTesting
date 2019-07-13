<javascript><![CDATA[
// ***DO NOT Modify above this line***
// Checks for greater or less than a number
function isGreaterOrLessThan(number, type, inclusive){
var testvalue = event.value;
if(testvalue != '')
{
if (type == 'greater') 
{
	if (inclusive)
	{
		if(testvalue >= number)
		{
			return true;
		}
		else
		{
			app.alert("The value must be greater than or equal to " + number + ".\n\nPlease try again!");
			event.value='';
		}
	}
	else
	{
		if(testvalue > number)
		{
			return true;
		}
		else
		{
			app.alert("The value must be greater than " + number + ".\n\nPlease try again!");
			event.value='';
		}
	}
}
else
{
	if (inclusive)
	{
		if(testvalue <= number)
		{
			return true;
		}
		else
		{
			app.alert("The value must be less than or equal to " + number + ".\n\nPlease try again!");
			event.value='';
		}
	}
	else
	{
		if(testvalue < number)
		{
			return true;
		}
		else
		{
			app.alert("The value must be less than " + number + ".\n\nPlease try again!");
			event.value='';
		}
	}

}
}
}

// Checks for number within a range
function isBetween(lower, upper, inclusive){
var testvalue = event.value;
if (testvalue != '')
{
if (inclusive)
{
	if((lower <= testvalue) && (testvalue <= upper))
	{
		return true;
	}
	else
	{
		app.alert("The value must be between " + lower + " and " + upper + ".\n\nPlease try again!");
		event.value='';
	}
}
else
{
	if((lower < testvalue) && (testvalue < upper))
	{
		return true;
	}
	else
	{
		app.alert("The value must be between " + lower + " and " + upper + ".\n\nPlease try again!");
		event.value='';
	}

}
}
}

// Checks for number outside a range
function isNotBetween(lower, upper, inclusive){
var testvalue = event.value;
if (testvalue != '')
{
if (inclusive)
{
	if((testvalue <= lower) || (testvalue >= upper))
	{
		return true;
	}
	else
	{
		app.alert("The value must not be between " + lower + " and " + upper + ".\n\nPlease try again!");
		event.value='';
	}
}
else
{
	if((testvalue < lower) || (testvalue > upper))
	{
		return true;
	}
	else
	{
		app.alert("The value must not be between " + lower + " and " + upper + ".\n\nPlease try again!");
		event.value='';
	}

}
}
}

// Only allow numeric input
function isNumeric(){
var numericExpression = /[0-9]/;
var content = event.change;
var fieldcontent = event.value;
if (content == '.')
{
	if (fieldcontent.indexOf('.') == -1)
	{
		return true;
	}
	else
	{
		event.change = "";
		return;
	}
}

if(content.match(numericExpression)) 
{
    	return true;	
}
else
{
	event.change = "";
}
}

// Only allow integer input
function isInteger(){
var numericExpression = /[0-9]/;
var content = event.change;
if(content.match(numericExpression)) 
{
    	return true;	
}
else
{
	event.change = "";
}
}

// Automatically check a checkbox when text is entered in the field
function autocheck(checkfield,textfield){
var textlength = this.getField(textfield).value.toString().length;
if (textlength > 0)
{
    this.getField(checkfield).value = checkfield.toString();
}
else
{
   this.getField(checkfield).value = "Off";
}
}
// Automatically check a checkbox when combobox is changed to a value
function combocheck(checkfield,combofield,exclude){
var combovalue = this.getField(combofield).value;
if (combovalue != exclude)
{
    this.getField(checkfield).value = checkfield.toString();
}
else
{
   this.getField(checkfield).value = "Off";
}
}
// Automatically check a checkbox when options are entered
function optioncheck(checkfield,optiongroup,numitems, exclude){
var options = this.getField(optiongroup);
if(options.value != exclude)
{
for (var i = 0; i < numitems; i++){
	if(options.isBoxChecked(i)){
		    this.getField(checkfield).value = checkfield.toString();
	}
}
}
else
{
   this.getField(checkfield).value = "Off";
}
}
// Automatically check a checkbox when options are entered
function checkcheck(checkfield,evalfield){
var evalcheck = this.getField(evalfield);
if(evalcheck.isBoxChecked(0)){
    this.getField(checkfield).value = checkfield.toString();
}
else
{
   this.getField(checkfield).value = "Off";
}
}
// Automatically check a checkbox when options are entered
function calctotal(){
    this.getField("total-grade").value = this.getField("multi-grade").value + this.getField("essay-grade").value; 
    this.getField("totalgrade").value = this.getField("multi-grade").value + this.getField("essay-grade").value;
    this.getField("essaygrade").value = this.getField("essay-grade").value;
}

// ***DO NOT Modify below this line***
]]></javascript>