set -e
K=CiCi-mascota
i=0
for s in reposo escuchando pensando escribiendo contenta sin-evidencia; do
  i=$((i+1))
  for v in c con-brazos; do
    F=work/frames/$v/$s/f%04d.png
    if [ $v = c ]; then D=$K/3-animaciones-en-bucle; P=cici-$i-$s; else D=$K/5-extra-version-con-brazos/animaciones-en-bucle; P=cici-brazos-$i-$s; fi
    mkdir -p "$D/MOV-ProRes4444-transparente" "$D/WebM-transparente" "$D/MP4-fondo-verde"
    ffmpeg -y -loglevel error -framerate 30 -i $F -c:v prores_ks -profile:v 4444 -pix_fmt yuva444p10le -vendor apl0 -qscale:v 11 "$D/MOV-ProRes4444-transparente/$P.mov"
    ffmpeg -y -loglevel error -framerate 30 -i $F -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf 30 -auto-alt-ref 0 -row-mt 1 "$D/WebM-transparente/$P.webm"
    ffmpeg -y -loglevel error -f lavfi -i color=c=0x00B140:s=1050x1200:r=30 -framerate 30 -i $F -filter_complex "[0][1]overlay=shortest=1,format=yuv420p" -c:v libx264 -crf 18 -preset slow -movflags +faststart "$D/MP4-fondo-verde/$P-verde.mp4"
  done
  echo $s
done
