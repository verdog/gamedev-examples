#pragma once

#include <string>

#include <SFML/Graphics.hpp>

struct Thing : public sf::Drawable {
   Thing(std::string file) {
      _tex.loadFromFile(file, sf::IntRect(0,0,64,64));
      _spr.setTexture(_tex);
      _spr.setOrigin(32,32);
   }

   void draw(sf::RenderTarget& target, sf::RenderStates states) const {
      target.draw(_spr, states);
   }

   void setPosition(float x, float y) {
      _spr.setPosition(x,y);
   }

   sf::Texture _tex;
   sf::Sprite _spr;
};

struct Words : public sf::Drawable {
   Words() {
      _font.loadFromFile("../resources/fonts/roboto/Roboto-Medium.ttf");
      _text.setFont(_font);
      _text.setString("xxx");
      _text.setCharacterSize(32);
      _text.setFillColor(sf::Color::White);
   }
   
   void setString(std::string str) {
      _text.setString(str);
   }

   void draw(sf::RenderTarget& target, sf::RenderStates states) const {
      target.draw(_text);
   }

   sf::Font _font;
   sf::Text _text;
};
