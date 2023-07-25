## Name
### AIColor

## Description
This is a package that will help users quickly find the necessary colors for their projects using 
only a text description

## Demo

[Demo video that shows the work of our package](https://drive.google.com/file/d/1jZw0fIcXW2txRJo6WXRLQ2ZSTbHYlzpN/view?usp=sharing)

## Getting started

Create an instance of variable for further convenient use
```dart
AIColor aiColor = AIColor("apiKey");//instead of "apikey" use your own API key
```

## Usage

Using an instance of AIColor and FutureBuilder, you can create various Widgets and set them the 
desired color with our library
```dart
Widget newWidget(String text){
  return FutureBuilder(
    future: aiColor.getColor(text),
    builder: (BuildContext context, AsyncSnapshot<Color?> snapshot) {
      if(snapshot.connectionState == ConnectionState.active ||
          snapshot.connectionState == ConnectionState.waiting){
        return const Center(child: CircularProgressIndicator(),);
      }
      if(snapshot.connectionState == ConnectionState.done){
        if(snapshot.hasError){
          return const Center(child: Text("ERROR"));
        }
        else {
          return Center(
            child: Container(
              width: 100,
              height: 100,
              color: snapshot.data,
            ),
          );
        }
      }
      return const Center(child: Text("wait"),);
    },

  );
}
```
Instead of the getColor function, you can use updateColor, which does not use the database, 
but sends a new request to ChatGPT each time


## Contributors

1. Ilnaz Magizov (@mazik_il)
2. Daniil Zimin (@daniilzimin4)
