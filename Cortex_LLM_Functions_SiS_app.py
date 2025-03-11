# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col

# Handle encoding -- THIS WOULD NEED WORK FOR PRODUCTION!
def clean_and_wrap(the_value):
    ret_val = the_value.replace("'", "\\'")
    return "\'" + ret_val + "\'"

# Write directly to the app
st.title("Explore Built-in Snowflake Cortex LLM Functions :brain:")

# Get the current credentials
session = get_active_session()

# default query
query = ""

tab_complete, tab_translate, tab_summarize, tab_sentiment, tab_answer, tab_classification = st.tabs(["Complete", "Translate", "Summarize", "Sentiment", "Extract Answer", "Classification"])

################################################################
#### Completion
################################################################
with tab_complete:
    st.header("Cortex-powered LLM Completion")

    llm = st.selectbox("LLM", ['claude-3-5-sonnet','llama2-70b-chat','mistral-large','mixtral-8x7b','gemma-7b','mistral-7b'])
    text_for_analysis = st.text_area("Prompt/Question")
    
    query = "select SNOWFLAKE.CORTEX.COMPLETE(" + clean_and_wrap(llm) + "," \
        + clean_and_wrap(text_for_analysis) + ")"

    # Display the resulting query
    st.code(query, language="sql")

    if text_for_analysis:

        # Do the sentiment!
        summary = session.sql(query).collect()    
        st.text_area("Generation Result", str(summary[0][0]))

################################################################
#### Translate
################################################################
with tab_translate:
    st.header("Cortex-powered Translation 🗼")
    
    # Beautify the dropdowns
    CHOICES = {"en": "English", "fr": "Francáis", "de": "Deutsch", "es": "Español"}
    def format_func(option):
        return CHOICES[option]
    
    # Layout
    col1, col2 = st.columns(2)
    
    # Get the input
    with col1:
        from_language = st.selectbox("From Language", options=list(CHOICES.keys()), format_func=format_func)
    
    with col2:
        to_language = st.selectbox("To Language", options=list(CHOICES.keys()), format_func=format_func)
    
    text_to_translate = st.text_input("Text to Translate")
    
    query = "select SNOWFLAKE.CORTEX.translate(" + clean_and_wrap(text_to_translate) + "," \
        + clean_and_wrap(from_language) + ", " \
        + clean_and_wrap(to_language) + ")"

    # Display the resulting query
    st.code(query, language="sql")

    if text_to_translate:
       
        # Do the translation!
        translation = session.sql(query).collect()    
        st.text_area("Translation", str(translation[0][0]))


################################################################
#### Summarize
################################################################
with tab_summarize:
    st.header("Cortex-powered Summarization")

    text_to_summarize = st.text_area("Text to Summarize")
    
    query = "select SNOWFLAKE.CORTEX.SUMMARIZE(" + clean_and_wrap(text_to_summarize) + ")"

    # Display the resulting query
    st.code(query, language="sql")

    if text_to_summarize:
        
        # Do the translation!
        summary = session.sql(query).collect()    
        st.text_area("Summary", str(summary[0][0]))


################################################################
#### Sentiment
################################################################
with tab_sentiment:
    st.header("Cortex-powered Sentiment")

    text_for_analysis = st.text_area("Text to Determine Sentiment")
    
    query = "select SNOWFLAKE.CORTEX.SENTIMENT(" + clean_and_wrap(text_for_analysis) + ")"

    # Display the resulting query
    st.code(query, language="sql")

    if text_for_analysis:
        st.session_state['query'] = query

        # Do the sentiment!
        summary = session.sql(query).collect()    
        st.text_input("Sentiment Score", str(summary[0][0]))




################################################################
#### Extract Answer
################################################################
with tab_answer:
    st.header("Cortex-powered LLM Answer Extraction")

    question = st.text_input("Question")
    text_for_analysis = st.text_area("Content to Analyze")
    
    query = "select SNOWFLAKE.CORTEX.EXTRACT_ANSWER(" \
        + clean_and_wrap(text_for_analysis) + "," \
        + clean_and_wrap(question) + ")"

    # Display the resulting query
    st.text_area("Resulting Query", query)

    if text_for_analysis and question:

        # Do the sentiment!
        summary = session.sql(query).collect()    
        st.text_area("Result", str(summary[0][0]))

################################################################
#### Classification
################################################################
with tab_classification:
    st.header("Cortex-powered LLM Topic Classification")

    text_to_classify = st.text_area("Text to classify as about pets or travel.")

    categories = st.text_input("Enter categories for classification in single quotes and separated by commas")

    query = "select SNOWFLAKE.CORTEX.CLASSIFY_TEXT("+ clean_and_wrap(text_to_classify) + "," + "[" +  categories + "]"+ ")"

    st.code(query, language="sql")

    if categories:
        classification = session.sql(query).collect()
        st.text_area("Result", str(classification[0][0]), key=2)

        
