Contribution Writer
========

## Write things in your GitHub contribution graph! ##

## Usage ##
    gem install git # TODO: add gemfile
    
    git clone https://github.com/psobot/contribution-writer.git 
    cd contribution-writer
    
    mkdir stupid_test
    cd stupid_test
    ruby ../forger.rb
    
    git push
    git remote add origin git@github.com:psobot/test_forge.git
    git push -u origin master
