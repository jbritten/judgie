// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var last_answered_question = "";

// Stores a question's DOM ID in a variable.  When another question
// is answered, the stored DOM ID will be removed from the page,
// and the new DOM ID will be stored in its place.
function remove_answered_question(dom_id)
{
	if(last_answered_question != "")
	{
		Effect.Fade(last_answered_question, {duration: 0.5});
		Effect.BlindUp(last_answered_question, {duration: 0.5});
	}
	last_answered_question = dom_id;
}