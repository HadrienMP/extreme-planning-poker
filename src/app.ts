import express from 'express';
import logger from "morgan";
import favicon from 'serve-favicon';
import { router as indexRouter } from './routes/Index';
import * as path from "path";

const app = express();

app.set('views', path.join(__dirname, '../views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, '../public')));
app.use(favicon(path.join(__dirname,'../public','images','favicon.ico')));
app.use(express.json());

app.use("/", indexRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
});