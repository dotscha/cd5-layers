stored=`grep byt scene_data.asm | sed s/byt/\ / | sed s/,/\ /g | wc -w`
labels=`grep -v byt scene_data.asm |wc -l`
dupl=`grep = scene_data.asm | grep -v + |wc -l`
echo all texture: `expr $labels \* 8`
echo stored texture: $stored
echo duplicated: `expr $dupl \* 8`
echo compessed: `expr $labels \* 8 - $stored - $dupl \* 8`
