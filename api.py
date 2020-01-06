from flask import Flask, request
from flask_restful import Resource, Api, reqparse, inputs
from scraper import findDup

app = Flask(__name__)
api = Api (app)

class PlaylistDuplicateFinder(Resource):
   def post(self):
      try:
         inputs.url(request.form['url'])
      except ValueError as e:
         return {'response': 'not a valid url'}, 400

      response = findDup(request.form['url'])
      return {
         'response': response
      }

api.add_resource(PlaylistDuplicateFinder, '/playlistDup')

if __name__ == '__main__':
   app.run(debug=True)