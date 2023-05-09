*** Settings ***
Library           SeleniumLibrary
Library           Collections
Library           BuiltIn

*** Variables ***
${IMDB_URL}       https://www.imdb.com/
${BROWSER}        chrome
${SEARCH_QUERY}    The Shawshank Redemption
${START_DATE}     2010
${END_DATE}       2020

*** Test Cases ***
FirstScenarioTC
    [Setup]    Open Browser    ${IMDB_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    id=suggestion-search
    Input Text    id=suggestion-search    ${SEARCH_QUERY}
    Click Button    id=suggestion-search-button
    Wait Until Page Contains Element    class:ipc-title__wrapper
    ${first_title}=    Get WebElement    class:ipc-metadata-list-summary-item__t
    ${first_title}    Get Text    ${first_title}
    ${results}=    Get WebElements    class:ipc-metadata-list-summary-item__t
    ${result_titles}=    Create List
    FOR    ${result}    IN    @{results}
        ${title}    Get Text    ${result}
        Append To List    ${result_titles}    ${title}
    END
    FOR    ${title}    IN    @{result_titles}
        Should Contain    ${title.lower()}    ${SEARCH_QUERY.lower()}
    END
    Should Be Equal As Strings    ${first_title.lower()}    ${SEARCH_QUERY.lower()}
    [Teardown]    Close Window

SecondScenarioTC
    [Setup]    Open Browser    ${IMDB_URL}    ${BROWSER}
    Maximize Browser Window
    Click Element    class:ipc-responsive-button__text
    Sleep    3
    Click Link    link:Top 250 Movies
    ${number}    Get Element Count    class:titleColumn
    Should Be Equal As Numbers    ${number}    250
    ${top}=    Get WebElement    class:titleColumn
    ${top}    Get Text    ${top}
    Should Contain    ${top.lower()}    ${SEARCH_QUERY.lower()}
    [Teardown]    Close Window

ThirdScenarioTC
    [Setup]    Open Browser    ${IMDB_URL}    ${BROWSER}
    Maximize Browser Window
    Click Element    xpath=//span[@class='ipc-btn__text' and contains(text(),'All')]
    Wait Until Page Contains Element    xpath://span[contains(text(), 'Advanced Search')]
    Click Element    xpath://span[contains(text(), 'Advanced Search')]
    Wait Until Page Contains Element    xpath://a[contains(text(), 'Advanced Title Search')]
    Click Link    link:Advanced Title Search
    Wait Until Page Contains Element    xpath://h1[contains(text(), 'Advanced Title Search')]
    Click Element    id=title_type-1
    Click Element    id=genres-1
    Input Text    name:release_date-min    ${START_DATE}
    Input Text    name:release_date-max    ${END_DATE}
    Click Button    class:primary
    Wait Until Page Contains Element    xpath://a[contains(text(), 'User Rating')]
    Click Link    link:User Rating
    ${movie_ratings}=    Get WebElements    xpath=//div[@class="inline-block ratings-imdb-rating"]/strong
    ${text_movie_ratings}    Create List
    FOR    ${rating}    IN    @{movie_ratings}
        ${rating}    Get Text    ${rating}
        ${rating}    Convert To Number    ${rating}
        Append To List    ${text_movie_ratings}    ${rating}
    END
    ${sorted_rating}=    Copy List    ${text_movie_ratings}
    Sort List    ${sorted_rating}
    Reverse List    ${sorted_rating}
    Lists Should Be Equal    ${text_movie_ratings}    ${sorted_rating}
    ${genres}=    Get WebElements    class:genre
    FOR    ${genre}    IN    @{genres}
        ${genre}    Get Text    ${genre}
        Should Contain    ${genre}    Action
    END
    ${movie_years}=    Get WebElements    xpath=//span[@class="lister-item-year text-muted unbold"]
    FOR    ${year}    IN    @{movie_years}
        ${year}    Get Text    ${year}
        Should Match Regexp    ${year}    201[0-9]|2020
    END
    [Teardown]    Close Window
