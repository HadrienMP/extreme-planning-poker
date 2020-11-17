const createError = require('http-errors');
const express = require('express');
const path = require('path');
const logger = require('morgan');
const favicon = require('serve-favicon');

const indexRouter = require('./back/routes/index');
const pollRouter = require('./back/routes/poll');
const nationRouter = require('./back/routes/nation');
const voteRouter = require('./back/routes/vote');

const app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(favicon(path.join(__dirname,'public','images','favicon.ico')));

app.use('/', indexRouter);
app.use('/poll', pollRouter);
app.use('/nation', nationRouter);
app.use('/vote', voteRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
