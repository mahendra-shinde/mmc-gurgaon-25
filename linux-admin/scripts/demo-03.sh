N1=10
N2=15
N3=$N1+$N2  # Values would be extracted but SHELL doesnt understand "+" operator yet !!!
echo "Answer $N3"	# Display 10+15
N3=$((N1+N2))	# $(( expr )) expr IS ARITHMETIC EXPRESSION 
echo "Answer $N3"       # Display 25
