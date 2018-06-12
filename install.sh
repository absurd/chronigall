#!/usr/bin/env bash

chmod +x find_local_file.sh
chmod +x left_center_pad.sh
chmod +x chronigall_timer.sh

chown $(whoami) find_local_file.sh
chown $(whoami) left_center_pad.sh
chown $(whoami) chronigall_timer.sh

chgrp $(whoami) find_local_file.sh
chgrp $(whoami) left_center_pad.sh
chgrp $(whoami) chronigall_timer.sh

ln -s "$(pwd)"/find_local_file.sh /usr/local/bin/findlocalest
ln -s "$(pwd)"/left_center_pad.sh /usr/local/bin/centerpad
ln -s "$(pwd)"/chronigall_timer.sh /usr/local/bin/chronigall
