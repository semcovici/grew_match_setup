# Porttinari
grew compile -i grew/grew_match_back/corpora/porttinari.json && grew compile -grew_match_server $DOCUMENT_ROOT/grew_match/meta -i grew/grew_match_back/corpora/porttinari.json 

# Dante
grew compile -i grew/grew_match_back/corpora/dante.json && grew compile -grew_match_server $DOCUMENT_ROOT/grew_match/meta -i grew/grew_match_back/corpora/dante.json 

# Frech
cd ~ && grew compile -i grew/grew_match_back/corpora/french.json && grew compile -grew_match_server $DOCUMENT_ROOT/grew_match/meta -i grew/grew_match_back/corpora/french.json 

# Limpar 
grew clean -i grew/grew_match_back/corpora/french.json && grew clean -i grew/grew_match_back/corpora/dante.json && grew clean -i grew/grew_match_back/corpora/porttinari.json  