```python
# Zicca Davide 

# pip install SpeechRecognition
# https://pypi.org/project/SpeechRecognition/
```


```python
# Importo la libreria necessaria
import speech_recognition as sr
```


```python
sr.__version__
```




    '3.8.1'




```python
r = sr.Recognizer()
```


```python
# Importo File Audio
Jim_Simons = sr.AudioFile('Jim_Simons_trading_2.wav')
with Jim_Simons as source:
    audio = r.record(source)
```


```python
type(audio)
```




    speech_recognition.AudioData




```python
# Utilizzo il Google Speech Recognition. Le alternative (CMU Sphinx, Google Cloud Speech API, 
# Wit.ai, Microsoft Bing Voice Recognition, Houndify API, IBM Speech to Text, 
# Snowboy Hotword Detection) richiedo dei token oppure l'iscrizione sul loro sito proprietario
# per poter utilizzare i loro algoritmi di riconoscimento vocale.
# Tuttavia, il Google Speech Recognition risulta essere fra i più consistenti e migliori da utilizzare.
# La presenza di funzioni (come 'adjust_for_ambient_noise' consente di migliorare i risultati di
# conversione audio.
r.recognize_google(audio)
```




    'goodbye my background as a mathematician we managed funds was trading as the trumpet by mathematical formulas we have only in a highly liquid publicly traded securities meaning with your trade and credit default swaps and collateralized debt obligations or some of those alphabet Soup things that George was just referring to our training miles actually tend to be contrarian happened buying stocks recently out of favour and selling those recently in favour'




```python
Jim_Simons = sr.AudioFile('Jim_Simons_trading_2.wav')
with Jim_Simons as source:
    r.adjust_for_ambient_noise(source) # in caso di audio con rumori di sottofondo, tende a migliorarne la conversione
    audio2 = r.record(source)
```


```python
r.recognize_google(audio2)
```




    "ground as a mathematician we managed funds was trading as the trumpet by mathematical formulas we have only and highly liquid publicly traded securities meaning with don't trade and credit default swaps and collateralized debt obligations or someone else alphabet Soup things that George was just referring to our training models actually tend to be contrarian happened buying stocks recently out of favour and selling those recently invited"




```python
Jim_Simons = sr.AudioFile('Jim_Simons_trading_2.wav')
with Jim_Simons as source:
    r.adjust_for_ambient_noise(source, duration=0.7)
    audio3 = r.record(source)
```


```python
r.recognize_google(audio3)
```




    'background as a mathematician we managed funds was trading as the trumpet by mathematical formulas we are only in a highly liquid publicly traded securities meaning with young trade and credit default swaps and collateralized debt obligations or some of those alphabet Soup things that George was just referring to our training models actually tend to be contrarian often buying stocks recently out of favour and selling those recently in favour'




```python
r.recognize_google(audio, show_all=True) # mostra tutte le possibili trascrizioni, piuttosto che mostrare
# solo quella scelta di default e ritenuta come migliore. In caso di file audio poco chiari, potrebbe essere
# utile leggere tutte le possibili trascrizioni.
```




    {'alternative': [{'transcript': 'goodbye my background as a mathematician we managed funds was trading as the trumpet by mathematical formulas we have only in a highly liquid publicly traded securities meaning with your trade and credit default swaps and collateralized debt obligations or some of those alphabet Soup things that George was just referring to our training miles actually tend to be contrarian happened buying stocks recently out of favour and selling those recently in favour',
       'confidence': 0.94311428},
      {'transcript': 'goodbye my background as a mathematician we managed funds was trading as the trumpet by mathematical formulas we have only in a highly liquid publicly traded securities meaning with your trade and credit default swaps and collateralized debt obligations or some of those alphabet Soup things that George was just referring to our training miles actually tend to be contrarian often buying stocks recently out of favour and selling those recently in forever'},
      {'transcript': 'goodbye my background as a mathematician we managed funds was trading as the trumpet by mathematical formulas we are only in a highly liquid publicly traded securities meaning with your trade and credit default swaps and collateralized debt obligations or some of those alphabet Soup things that George was just referring to our training miles actually tend to be contrarian happened buying stocks recently out of favour and selling those recently in favour'},
      {'transcript': 'goodbye my background as a mathematician we managed funds was trading as the trumpet by mathematical formulas we have only in a highly liquid publicly traded securities meaning with your trade and credit default swaps and collateralized debt obligations or some of those alphabet Soup things that George was just referring to our training miles actually tend to be contrarian happened buying stocks recently out of favour and selling those recently in forever'},
      {'transcript': 'goodbye my background as a mathematician we managed funds was trading as the trumpet by mathematical formulas we are only in a highly liquid publicly traded securities meaning with your trade and credit default swaps and collateralized debt obligations or some of those alphabet Soup things that George was just referring to our training miles actually tend to be contrarian often buying stocks recently out of favour and selling those recently in forever'}],
     'final': True}




```python
# Utilizzo 'offset' e 'duration' per estrapolare una trascrizione riferita ad un istante
# temporale di interesse.
# I valori inseriti in 'offset' e 'duration' sono da intendersi come secondi della traccia audio.
Jim_Simons = sr.AudioFile('Jim_Simons_trading_2.wav')
with Jim_Simons as source:
    audio4 = r.record(source, offset=3, duration=2)

r.recognize_google(audio4)
```




    'we managed'



# Metodo Alternativo


```python
# Installo jovian
# !pip install jovian --upgrade
# Installo Transformer
# !pip install -q transformers
# Installo librosa
# !pip install librosa
# Installo torch
# !pip install torch
```


```python
# Importo le libraries
import jovian
# Libreria per gestire i file audio
import librosa
# Importo Pytorch
import torch
# Importo Wav2Vec tokenizer
from transformers import Wav2Vec2ForCTC, Wav2Vec2Tokenizer
```


```python
# Carico l'audio di interesse
# Audio in formato 16 kHz
# https://www.youtube.com/watch?v=MExqWefHv2A&ab_channel=Pairtrading
# 'What is the Best Trading Strategy?' --> Jim Simons

import IPython.display as display
display.Audio("Jim_Simons_trading_2.wav", autoplay=False)
```





<audio  controls="controls" >
    Your browser does not support the audio element.
</audio>





```python
# Importo 'Wav2Vec pretrained model'
tokenizer = Wav2Vec2Tokenizer.from_pretrained("facebook/wav2vec2-base-960h")
model = Wav2Vec2ForCTC.from_pretrained("facebook/wav2vec2-base-960h")
```

    C:\ProgramData\Anaconda3\lib\site-packages\transformers\models\wav2vec2\tokenization_wav2vec2.py:356: FutureWarning: The class `Wav2Vec2Tokenizer` is deprecated and will be removed in version 5 of Transformers. Please use `Wav2Vec2Processor` or `Wav2Vec2CTCTokenizer` instead.
      warnings.warn(
    Some weights of Wav2Vec2ForCTC were not initialized from the model checkpoint at facebook/wav2vec2-base-960h and are newly initialized: ['wav2vec2.masked_spec_embed']
    You should probably TRAIN this model on a down-stream task to be able to use it for predictions and inference.
    


```python
# Passo il file audio a 'librosa'
audio, rate = librosa.load("Jim_Simons_trading_2.wav", sr = 16000)
```


```python
# Mostro l'audio 
audio
```




    array([ 0.        ,  0.        ,  0.        , ..., -0.00018311,
           -0.00018311, -0.00018311], dtype=float32)




```python
# Mostro il rate per assicurarmi che sia compatibile --> 16 kHz
rate
```




    16000




```python
# Funzioni necessarie per il modello Wav2Vec2
input_values = tokenizer(audio, return_tensors = "pt").input_values
```


```python
input_values
```




    tensor([[-8.9660e-05, -8.9660e-05, -8.9660e-05,  ..., -5.2166e-03,
             -5.2166e-03, -5.2166e-03]])




```python
# Storing logits (non-normalized prediction values) --> funzioni necessarie per il modello Wav2Vec2
logits = model(input_values).logits
```


```python
# Storing predicted id's --> funzioni necessarie per il modello Wav2Vec2 
prediction = torch.argmax(logits, dim = -1)
```


```python
# Passing the prediction to the tokenzer decode to get the transcription --> funzioni necessarie per il modello Wav2Vec2
transcription = tokenizer.batch_decode(prediction)[0]
print(transcription) # Mostro la trascrizione del file audio di prova
```

    VEN BY MY BACKGROUND AS A MATHEMATICIAN WE MANAGE FUNDS WHOSE TRADING IS DETERMINED BY MATHEMATICALFONIOS WE OPERATE ONLY IN A HIGHLY LIQUID PUBLICLY TRADED SECURITIES MEANING WE DON'T TRADE AND CREDIT THE FALSWAPS OR COLLATERIZED DAD OBLIGATIONS OR SOME OF THOSE ALPHABITE SOUP THINGS THAT GEORGE WAS JUST REFERRING TO OUR TRADING MODELS ACTUALLY TEND TO BE CONTRARIAN OFTEN BUYING STOCKS RECENTLY OUT OF FAVOR AND SELLING NOSE RECENTLY IN FAVOR
    