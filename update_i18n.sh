#!/bin/sh
xgettext.pl --output=lib/RG3Redir/I18N/messages.pot --directory=lib/ --directory=root/
msgmerge --update lib/RG3Redir/I18N/pt.po lib/RG3Redir/I18N/messages.pot
msgmerge --update lib/RG3Redir/I18N/en.po lib/RG3Redir/I18N/messages.pot

