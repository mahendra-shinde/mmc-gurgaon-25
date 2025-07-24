N2=15
N3=$N1+$N2  # N1 is ENV VARIABLE and N2 is LOCAL VAR
echo "Answer $N3"	# Display 10+15
N3=$((N1+N2))	# $(( expr )) expr IS ARITHMETIC EXPRESSION 
echo "Answer $N3"       # Display 25
