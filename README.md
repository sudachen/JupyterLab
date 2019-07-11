

```
cd $HOME
git clone git@github.com:sudachen/JupyterLab
cd ~/JupyterLab
./up
```

Now open http://localhost:8888

`./up` starts JupyterLab server and MySQL 5.7 database in container. The `Work` folder in Jupyter Home is mapped to ~/Work, also `Project` is mapped to the ~/Project. Database files can be found in ~/JupyterLab/MySql directory. To cennect MySQL database use `mysql -h 127.0.0.1 -ulab -plab` or `mysql -h 127.0.0.1 -uroot -ptoor`. Database server is not accessable from the network and accepts connection only from the localhost.

To add/change mapping folders edit this part of Config/docker-compose.yml
```yml
    volumes:
      - ${HOME}/.ssh:/lab/.ssh
      - ${HOME}/Work:/lab/work/Work:Z
      - ${HOME}/Projects:/lab/work/Projects
 ```
