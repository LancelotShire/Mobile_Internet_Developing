class Tools {
  List lyricsAnalyzer(Duration duration, List lyrics) {
    var time = duration.inSeconds+0.1;
    String formerLyric = "";
    String currentLyric = "";
    String nextLyric = "";
    for(int i = 0;i < lyrics.length;i++){
      if ((time>=lyrics[i][0]&&i+1==lyrics.length)||(time>=lyrics[i][0]&&time<lyrics[i+1][0])){
        if(i-1>=0){
          formerLyric = lyrics[i-1][1];
        }
        if(i+1<lyrics.length){
          nextLyric = lyrics[i+1][1];
        }
        currentLyric = lyrics[i][1];
        break;
      }
    }
    return [formerLyric,currentLyric,nextLyric];
  }
}