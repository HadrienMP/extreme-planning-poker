import express, {Request, Response} from 'express';
import logger from "morgan";
import favicon from 'serve-favicon';
import * as sse from './infrastructure/sse';
import * as path from "path";
import * as bus from "./infrastructure/bus"
import * as nation from "./nation/routes";
import * as poll from "./poll/routes";
import * as vote from "./vote/routes";

const app = express();

app.set('views', path.join(__dirname, '../views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, '../public')));
app.use(favicon(path.join(__dirname,'../public','images','favicon.ico')));
app.use(express.json());

app.get('/', (req: Request, res: Response) => { res.render('index'); });
app.use("/sse", sse.init);
app.use("/nation", nation.router);
app.use("/poll", poll.router);
app.use("/vote", vote.router);
bus.init();


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
});