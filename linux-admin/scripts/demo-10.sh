oneMore=Y
while [ "$oneMore" = "Y" ] || [ "$oneMore" = "y"  ]; do
	fortune -n 1 | cowsay -f tux
	read -p "Do you want more ?" oneMore
done
